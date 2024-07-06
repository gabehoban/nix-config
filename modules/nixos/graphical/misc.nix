{ pkgs, ... }:
{
  # Enable X11, but get rid of xterm
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.xserver.desktopManager.xterm.enable = false;

  # Enable CUPS for printers
  services.printing.enable = true;
  # Enable SANE for scanners
  hardware.sane.enable = true;
  # Enable Avahi for printer discovery
  services.avahi.enable = true;
  programs.system-config-printer.enable = true;

  environment.systemPackages = [ pkgs.firefox ];

  # 1Password
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "gabehoban" ];
  };

  # Some packages aren't on nixpkgs
  services.flatpak.enable = true;
  services.pcscd.enable = true;
}
