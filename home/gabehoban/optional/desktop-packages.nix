{ pkgs, ... }:
{

  home.packages = with pkgs; [
    spotify
    terminator
    evince
    thunderbird
    yubikey-manager
    appimage-run
    wakeonlan
    game-devices-udev-rules
    remmina

    # Unstable pkgs
    unstable.hexchat
    unstable.ollama
    unstable.hugo
    unstable.xonotic
    unstable.jellyfin-media-player
    unstable.usbutils
    unstable.obsidian
  ];

}
