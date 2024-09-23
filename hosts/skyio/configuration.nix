{
  inputs,
  vars,
  pkgs,
  ...
}:
{
  imports = [
    inputs.hardware.nixosModules.raspberry-pi-4
    ./hardware-configuration.nix
  ];

  console.enable = false;
  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  home-manager = {
    useUserPackages = true;
    users.${vars.username} = {
      imports = [
        inputs.nix-index-database.hmModules.nix-index
        ../../modules/home/user
        ../../modules/home/programs/terminal
      ];
    };
  };

  networking.hostName = "skyio";
  networking.networkmanager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
