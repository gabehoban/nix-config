{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../disko/baymax.nix
    # Defaults on all hosts
    ../common/_global
    # Hardware
    ../common/hardware/nvidia.nix
    ../common/hardware/bluetooth.nix
    ../common/hardware/yubikey.nix
    # Desktop
    ../common/desktops/gnome.nix
    # Applications
    ../common/apps/_1password.nix
    ../common/apps/firefox.nix
    ../common/apps/steam.nix
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

  networking.hostName = "baymax";
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
