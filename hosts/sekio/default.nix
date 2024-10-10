{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/profiles/sekio.nix
  ];

  nixpkgs = {
    overlays = [
      (_final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];
  };

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
    git
    neovim
  ];
  hardware = {
    raspberry-pi."4" = {
      apply-overlays-dtmerge.enable = true;
    };
    deviceTree.enable = true;
  };
}
