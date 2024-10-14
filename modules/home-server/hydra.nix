{ lib, config, ... }:
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

    sops.secrets."nix-cache-privkey" = {
      sopsFile = ../../secrets/hydra.yaml;
      owner = "harmonia";
      mode = "600";
    };

    services.harmonia = {
      enable = true;
      signKeyPaths = [ config.sops.secrets."nix-cache-privkey".path ];
      settings = {
        bind = "0.0.0.0:5000";
        priority = 50;
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
        locations."= /" = {
          return = ''200 'Nix Cache by gabehoban\n\nPublic key:\n\n  nix-cache.lab4.cc:B5eUOBimkQFrWTTF2e7fRKm/j7EyTnJ4SgvXu804fs8=\n\nNixOS Configuration:\n\n  nix.settings = {\n    substituters = [\n      "https://nix-cache.lab4.cc"\n    ];\n    trusted-public-keys = [\n      "nix-cache.lab4.cc:B5eUOBimkQFrWTTF2e7fRKm/j7EyTnJ4SgvXu804fs8="\n    ];\n  }\n\nTry:\n\n  nix build --substituters "https://nix-cache.lab4.cc" \\\n  --trusted-public-keys "nix-cache.lab4.cc:B5eUOBimkQFrWTTF2e7fRKm/j7EyTnJ4SgvXu804fs8=" \\\n  "git+https://git.clerie.de/clerie/fieldpoc.git#fieldpoc"\n\n.-*..*-.' '';
          extraConfig = ''
            types { } default_type "text/plain; charset=utf-8";
          '';
        };
        locations."/" = {
          proxyPass = "http://localhost:5000";
          extraConfig = ''
            proxy_redirect http:// https://;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
          '';
        };
      };
    };
  };
}
