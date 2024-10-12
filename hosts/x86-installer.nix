{
  vars,
  self,
  lib,
  ...
}:
{
  imports = [ self.nixosModules.syscfgOS ];
  networking.hostName = "syscfgOS-installer";
  networking.hostId = "00000000";
  nixpkgs.hostPlatform = "x86_64-linux";

  syscfg = {
    graphics.gnome = true;
    profiles.base = true;
    security.harden = false;
  };

  services.displayManager.autoLogin = {
    enable = true;
    inherit (vars) user;
  };
  services.xserver.displayManager.gdm.autoSuspend = false;

  system.stateVersion = "24.05";

  hardware.enableRedistributableFirmware = true;
  services.openssh.enable = true;
  networking.firewall.enable = false;
  services.getty.autologinUser = vars.user;

  users.users.${vars.user} = {
    isNormalUser = true;
    hashedPassword = "$7$CU..../....XLf//C9LnU4RhPpz8kVoe1$HIAtla6LnHT6BYsYqBbAXmWAJ1..nNBoRw4awirwQJ9";
    hashedPasswordFile = lib.mkForce null;
  };
}
