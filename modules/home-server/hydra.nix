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
    services.hydra = {
      enable = true;
      hydraURL = "https://hydra.lab4.cc";
      listenHost = "localhost";
      port = 3300;
      notificationSender = "hydra@localhost";
      useSubstitutes = true;
      extraConfig = ''
        binary_cache_public_uri = https://nix-cache.lab4.cc
      '';
    };

    nix.settings.allowed-uris = "github: git+https://github.com/ git+ssh://github.com/ https://github.com/ https://raw.githubusercontent.com/NixOS/nixpkgs/";
    nix.extraOptions = ''
      allowed-uris = github: git+https://github.com/ git+ssh://github.com/ https://github.com/ https://raw.githubusercontent.com/NixOS/nixpkgs/
    '';

    nix.settings.trusted-users = [
      "root"
      "hydra"
      "hydra-www"
    ];

    nix = {
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
    };

    sops.secrets."attic-credentials" = {
      sopsFile = ../../secrets/hydra.yaml;
      mode = "600";
    };

    environment.systemPackages = [ pkgs.attic-client ];

    services.atticd = {
      enable = true;
      credentialsFile = config.sops.secrets.attic-credentials.path;

      settings = {
        listen = "127.0.0.1:8080";

        api-endpoint = "https://nix-cache.lab4.cc/";
        soft-delete-caches = false;
        require-proof-of-possession = true;

        storage = {
          type = "s3";
          region = "us-east-1";
          bucket = "attic-cache";
          endpoint = "http://100.114.122.47:9000";
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

    services.nginx.virtualHosts = {
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
}
