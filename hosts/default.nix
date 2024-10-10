{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations =
    let
      inherit (inputs.nixpkgs.lib) nixosSystem;
      specialArgs = {
        inherit user inputs self;
      };
      homeImports = import "${self}/home/profiles";
      user = "gabehoban";
    in
    {
      # Desktop
      baymax = nixosSystem {
        inherit specialArgs;
        modules = [
          { networking.hostName = "baymax"; }
          ./baymax

          {
            home-manager = {
              users.${user}.imports = homeImports.baymax;
              extraSpecialArgs = specialArgs;
            };
          }
        ];
      };

      # VPS server
      vpsio = nixosSystem {
        inherit specialArgs;
        modules = [
          inputs.attic.nixosModules.atticd
          { networking.hostName = "vpsio"; }
          ./vpsio

          {
            home-manager = {
              users.${user}.imports = homeImports.vpsio;
              extraSpecialArgs = specialArgs;
            };
          }
        ];
      };

      # RPI4 server
      sekio = nixosSystem {
        inherit specialArgs;
        modules = [
          inputs.nixos-hardware.nixosModules.raspberry-pi-4
          { networking.hostName = "sekio"; }
          ./sekio

          {
            home-manager = {
              users.${user}.imports = homeImports.sekio;
              extraSpecialArgs = specialArgs;
            };
          }
        ];
      };
    };

  flake.darwinConfigurations =
    let
      inherit (inputs.darwin.lib) darwinSystem;
      specialArgs = {
        inherit user inputs self;
      };
      homeImports = import "${self}/home/profiles";
      user = "gabehoban";
    in
    {
      # Macbook Pro M2
      macbook = darwinSystem {
        inherit specialArgs;
        modules = [
          { networking.hostName = "macbook"; }
          ./macbook
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              users.${user}.imports = homeImports.macbook;
              extraSpecialArgs = specialArgs;
            };
          }
        ];
        system = "aarch64-darwin";
      };
    };
}
