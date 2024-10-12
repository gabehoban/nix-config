{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
let
  cfg = config.syscfg.graphics;
  inherit (lib)
    mkOption
    types
    mkIf
    ;
in
{
  imports = [
    ./gnome.nix
    ./apps.nix
    ./nvidia.nix
  ];
  options.syscfg.graphics = {
    enable = mkOption {
      description = "Sets up the graphical user environment with X11";
      type = types.bool;
      default = cfg.gnome;
    };
  };
  config = mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    hardware.pulseaudio.enable = false;

    programs.dconf.enable = true;

    services.xserver.enable = true;
    services.xserver.excludePackages = [ pkgs.xterm ];
    services.xserver.displayManager.gdm.enable = true;

    # Make system look better overall when we have a graphical system
    boot.plymouth = {
      enable = true;
    };

    home-manager.users."${vars.user}" = {
      # Default themeing for GTK and Qt
      qt = {
        enable = true;
        #platformTheme.name = "gtk";
        #style.package = pkgs.adwaita-qt;
        #style.name = "adwaita-dark";
      };

      gtk = {
        enable = true;
        #theme.name = "Adwaita-dark";
        #gtk3.extraConfig = {
        #  gtk-application-prefer-dark-theme = true;
        #  gtk-cursor-theme-name = "Adwaita";
        #};
      };

      xsession.enable = true;
      xsession.profileExtra = "export PATH=$PATH:$HOME/.bin";
    };
  };
}
