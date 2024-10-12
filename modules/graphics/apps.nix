{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.syscfg.graphics;
in
{
  options.syscfg.graphics = {
    apps = lib.mkEnableOption "workstation graphical applications";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.apps {
      # Fonts
      fonts = {
        enableDefaultPackages = true;
        enableGhostscriptFonts = true;
        packages =
          with pkgs;
          [
            roboto
            ubuntu_font_family
            fira-code
            cantarell-fonts
            freefont_ttf
            inconsolata
            liberation_ttf
            lmodern
            ttf_bitstream_vera
            inter
            ibm-plex
            merriweather
            jetbrains-mono
            # Bitmap fonts
            terminus_font
          ]
          ++ [
            (nerdfonts.override {
              fonts = [
                "FiraCode"
                "JetBrainsMono"
              ];
            })
          ];
      };
    })
    (lib.mkIf cfg.apps {
      # On VMs, these applications would reside on the host.
      environment.systemPackages = with pkgs; [
        rpi-imager
        gnome-firmware

        # Re-add GNOME apps that are needed
        evince
        gnome.gnome-system-monitor
        gnome-text-editor
        loupe
        gnome-obfuscate
      ];
      services.fwupd.enable = true;
      services.power-profiles-daemon.enable = true;
    })
  ];
}
