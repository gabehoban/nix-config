{
  inputs,
  self,
  lib,
  vars,
  ...
}:
{
  flake =
    let
      specialArgs = {
        inherit self inputs vars;
      };
    in
    {
      nixosModules = {
        host-baymax = import ./baymax;
        host-casio = import ./casio;
        host-sekio = import ./sekio;
        host-vpsio = import ./vpsio;
        host-srvio = import ./srvio;

        # Generators hosts
        host-rpi4-bootstrap = import ./rpi4-bootstrap.nix;
        host-x86-installer = import ./x86-installer.nix;
      };
      nixosConfigurations = {
        baymax = lib.nixosSystem {
          inherit specialArgs;
          modules = [ self.nixosModules.host-baymax ];
        };
        casio = lib.nixosSystem {
          inherit specialArgs;
          modules = [ self.nixosModules.host-casio ];
        };
        sekio = lib.nixosSystem {
          inherit specialArgs;
          modules = [ self.nixosModules.host-sekio ];
        };
        vpsio = lib.nixosSystem {
          inherit specialArgs;
          modules = [ self.nixosModules.host-vpsio ];
        };
        srvio = lib.nixosSystem {
          inherit specialArgs;
          modules = [ self.nixosModules.host-srvio ];
        };

      };

      packages.x86_64-linux = {
        installer = inputs.nixos-generators.nixosGenerate {
          format = "iso";
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            self.nixosModules.host-x86-installer
            {
              isoImage = {
                squashfsCompression = "zstd -Xcompression-level 6";
              };
            }
          ];
        };
      };

      packages.aarch64-linux = {
        rpi4-bootstrap = inputs.nixos-generators.nixosGenerate {
          format = "sd-aarch64";
          system = "aarch64-linux";
          inherit specialArgs;
          modules = [
            self.nixosModules.host-rpi4-bootstrap
            { sdImage.compressImage = false; }
          ];
        };
      };

      deploy.nodes = {
        vpsio = {
          hostname = "vpsio.lab4.cc";
          sshUser = "root";
          sshOpts = [
            "-p"
            "30"
          ];
          profiles.system = {
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.vpsio;
          };
        };
        sekio = {
          hostname = "sekio.lab4.cc";
          sshUser = "root";
          sshOpts = [
            "-p"
            "30"
          ];
          profiles.system = {
            path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.sekio;
          };
        };
        srvio = {
          hostname = "srvio.lab4.cc";
          sshUser = "root";
          sshOpts = [
            "-p"
            "30"
          ];
          profiles.system = {
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.srvio;
          };
        };
      };

      hydraJobs = {
        x86_64-linux = {
          baymax = self.nixosConfigurations.baymax.config.system.build.toplevel;
          vpsio = self.nixosConfigurations.vpsio.config.system.build.toplevel;
          srvio = self.nixosConfigurations.srvio.config.system.build.toplevel;
        };
        # aarch64-linux = {
        #   casio = self.nixosConfigurations.casio.config.system.build.toplevel;
        #   sekio = self.nixosConfigurations.sekio.config.system.build.toplevel;
        # };
      };
    };
}
