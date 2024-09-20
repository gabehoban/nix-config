{ inputs, config, pkgs,  ... }: {
  imports =
    [
      ./hardware-configuration.nix
      ../common/global
      ../common/optional/docker.nix
      ../common/optional/roles/workstation/nvidia.nix
      ../common/optional/roles/workstation/gnome.nix
      ../common/optional/roles/workstation/steam.nix
      ../common/optional/roles/workstation/bluetooth.nix
      ../../disko/pc-baymax.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [
    unstable.nvidia-docker
    unstable.flameshot
  ];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableHardening = false;
  users.extraGroups.vboxusers.members = [ "gabehoban" ];

  hardware.nvidia-container-toolkit.enable = true;

  networking.hostName = "pc-baymax";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.dconf.enable = true;

 # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";

}

