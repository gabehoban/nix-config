{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.syscfg.server;
in
{
  options.syscfg.server.hydra = lib.mkOption {
    description = "Enables Hydra Build Server";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf cfg.hydra {
    nix = {
      settings = {
        trusted-users = [
          "root"
          "hydra"
          "hydra-www"
        ];
        allowed-uris = "github: git+https://github.com/ git+ssh://github.com/ https://github.com/ https://raw.githubusercontent.com/NixOS/nixpkgs/";
      };
      buildMachines = [
        {
          hostName = "localhost";
          protocol = null;
          systems = [
            "x86_64-linux"
            "aarch64-linux"
            "i686-linux"
            "riscv64-linux"
          ];
          supportedFeatures = [
            "kvm"
            "nixos-test"
            "big-parallel"
            "benchmark"
            "local"
          ];
          maxJobs = 2;
        }
      ];
      extraOptions = ''
        allowed-uris = github: git+https://github.com/ git+ssh://github.com/ https://github.com/ https://raw.githubusercontent.com/NixOS/nixpkgs/
      '';
    };

    sops.secrets = {
      "attic-auth-token" = {
        sopsFile = ../../secrets/hydra.yaml;
      };
      "attic-credentials" = {
        sopsFile = ../../secrets/hydra.yaml;
        mode = "600";
      };
    };

    environment.systemPackages = [ pkgs.attic-client ];

    services = {
      hydra = {
        enable = true;
        hydraURL = "https://hydra.lab4.cc";
        listenHost = "localhost";
        port = 3300;
        notificationSender = "hydra@localhost";
        useSubstitutes = true;
        extraConfig = ''
          binary_cache_public_uri = https://nix-cache.lab4.cc/main
        '';
      };
      atticd = {
        enable = true;
        environmentFile = config.sops.secrets."attic-credentials".path;

        settings = {
          listen = "127.0.0.1:8080";

          api-endpoint = "https://nix-cache.lab4.cc/";
          soft-delete-caches = false;
          require-proof-of-possession = true;

          storage = {
            type = "s3";
            region = "us-east-1";
            bucket = "attic-cache";
            endpoint = "https://s3.lab4.cc";
          };

          # Data chunking
          chunking = {
            nar-size-threshold = 64 * 1024; # 64 KiB
            min-size = 16 * 1024; # 16 KiB
            avg-size = 64 * 1024; # 64 KiB
            max-size = 256 * 1024; # 256 KiB
          };
          compression = {
            type = "zstd";
            level = 8;
          };
        };
      };

      nginx.virtualHosts = {
        "hydra.lab4.cc" = {
          enableACME = true;
          forceSSL = true;
          acmeRoot = null;
          locations = {
            "/" = {
              proxyPass = "http://localhost:3300";
            };
          };
        };
        "nix-cache.lab4.cc" = {
          enableACME = true;
          forceSSL = true;
          acmeRoot = null;
          locations."/" = {
            proxyPass = "http://localhost:8080";
            extraConfig = ''
              proxy_redirect http:// https://;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection $connection_upgrade;
            '';
          };
        };
      };
    };
    systemd.services.attic-watch-store = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [
        "network-online.target"
        "atticd.service"
      ];
      environment.HOME = "/run/attic-watch-store";
      serviceConfig = {
        MemoryHigh = "5%";
        MemoryMax = "10%";
      };
      path = [ pkgs.attic-client ];
      script = ''
        set -eux -o pipefail
        ATTIC_TOKEN=$(< ${config.sops.secrets.attic-auth-token.path})
        # Replace https://cache.<domain> with your own cache URL.
        attic login nix-cache https://nix-cache.lab4.cc $ATTIC_TOKEN
        attic use main
        exec attic watch-store nix-cache:main
      '';
    };
  };
}
