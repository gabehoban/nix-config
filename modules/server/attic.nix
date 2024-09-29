{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  getAdminToken = pkgs.writeShellScriptBin "attic-admin-token" ''
    atticd-atticadm make-token --sub "vpsio-srv" \
      --validity "1day" \
      --push "*" \
      --pull "*" \
      --delete "*" \
      --configure-cache-retention "*" \
      --create-cache "*" \
      --configure-cache "*" \
      --destroy-cache "*"
  '';

  atticAdminLogin = pkgs.writeShellScriptBin "attic-admin-login" ''
    TOKEN=$(${getAdminToken}/bin/attic-admin-token)
    attic login local https://cache.lab4.cc --set-default $token
  '';

in
{
  age.secrets.attic-creds.rekeyFile = "${inputs.self.outPath}/secrets/attic-creds.age";
  age.secrets.attic-admin-token = {
    rekeyFile = "${inputs.self.outPath}/secrets/attic-admin-token.age";
    owner = "atticd";
  };

  services.atticd = {
    enable = true;
    credentialsFile = config.age.secrets.attic-creds.path;

    settings = {
      listen = "127.0.0.1:8080";
      api-endpoint = "https://cache.lab4.cc/";
      database.url = "postgres://atticd?host=/run/postgresql&user=atticd";

      # Data chunking
      #
      # Warning: If you change any of the values here, it will be
      # difficult to reuse existing chunks for newly-uploaded NARs
      # since the cutpoints will be different. As a result, the
      # deduplication ratio will suffer for a while after the change.
      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };
    };
  };
  services.nginx.virtualHosts = {
    "cache.lab4.cc" = {
      forceSSL = true;
      enableACME = true;
      quic = true;
      http3 = true;
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:8080";
          proxyWebsockets = true;
        };
      };
      extraConfig = ''
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
      '';
    };
  };

  services.postgresql = {
    ensureDatabases = [ "atticd" ];
    ensureUsers = [
      {
        name = "atticd";
        ensureDBOwnership = true;
      }
    ];
  };

  systemd.services.atticd = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };

  systemd.timers."nix-cache-build" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* *:00:00";
      Unit = "nix-cache-build.service";
    };
  };

  # sudo systemctl start nix-cache-build.service
  systemd.services."nix-cache-build" = {
    path = with pkgs; [
      git
      nixos-rebuild
      attic-client
    ];
    environment = {
      HOME = "/run/nix-cache-build";
      XDG_CONFIG_HOME = "/run/nix-cache-build/config";
    };
    script =
      let
        hosts = [
          "baymax"
          "vpsio"
        ];
        buildAndPush = host: ''
          echo "BUILDING ${host}"
          (nixos-rebuild build --flake /tmp/nixos-configs#${host} && attic push main ./result/) || true
        '';
        buildSteps = lib.concatMapStringsSep "\n" buildAndPush hosts;
      in
      ''
        set -eu
        rm -rf /tmp/nixos-configs
        attic login --set-default local https://cache.lab4.cc "$(cat ${config.age.secrets.attic-admin-token.path})"
        attic cache info main

        git clone https://github.com/gabehoban/nix-config /tmp/nixos-configs

        ${buildSteps}

        rm -rf /tmp/nixos-configs
      '';
    serviceConfig = {
      Type = "oneshot";
      RuntimeDirectory = "nix-cache-build";
      WorkingDirectory = "/run/nix-cache-build";
      RuntimeDirectoryPreserve = true;
    };
  };

  environment.systemPackages = [
    atticAdminLogin
    pkgs.attic-client
  ];
}
