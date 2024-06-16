{ config, desktop, hostname, inputs, lib, pkgs, platform, username, ... }:
let
  isWorkstation = if (desktop != null) then true else false;
in
{
  environment = {
    # Desktop environment applications/features I don't use or want
    gnome.excludePackages = with pkgs; [
      baobab
      gnome-console
      gnome-text-editor
      gnome.epiphany
      gnome.geary
      gnome.gnome-music
      gnome.gnome-system-monitor
      gnome.totem
    ];

    systemPackages = (with pkgs; [
      _1password
    ] ++ lib.optionals (isWorkstation) [
      _1password-gui
      firefox
      celluloid
      element-desktop
      fractal
      gimp-with-plugins
      gnome.dconf-editor
      gnome.gnome-sound-recorder
      halloy
      meld
      pika-backup
      usbimager
      gnupg
      yubikey-personalization
    ] ++ lib.optionals (isWorkstation && (desktop == "gnome")) [
      loupe
      marker
    ] ++ lib.optionals (isWorkstation && desktop == "gnome") [
      blackbox-terminal
      gnome-extension-manager
      gnomeExtensions.start-overlay-in-application-view
      gnomeExtensions.tiling-assistant
      gnomeExtensions.vitals
    ]);
  };

  services = {
    pcscd.enable = true;
    udev.packages = with pkgs; [ yubikey-personalization ];
  };

  programs = {
    dconf.profiles.user.databases = [{
      settings = with lib.gvariant; lib.mkIf (isWorkstation) {
      };
    }];
  };

  users.users.gabehoban = {
    description = "Gabriel Hoban";
    # mkpasswd -m sha-512
    hashedPassword = "$6$UjZO9G9dKhu2sNZn$o2qhOSeQw1dxdCcrwECwMwQ.pc2XaNPbiB8IaYtJwzdYV.q5FfaGH3BoPtwTzDwlfOrYQpYvokiw2lKdwlqqq0";
  };

  systemd.tmpfiles.rules = [
    "d /mnt/snapshot/${username} 0755 ${username} users"
  ];
}