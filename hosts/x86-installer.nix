{
  vars,
  self,
  lib,
  ...
}:
{
  imports = [ self.nixosModules.syscfgOS ];
  networking = {
    hostName = "syscfgOS-installer";
    hostId = "00000000";
  };
  nixpkgs.hostPlatform = "x86_64-linux";

  syscfg = {
    graphics.gnome = true;
    profiles.base = true;
    security.harden = false;
  };

  services = {
    openssh.enable = true;
    getty.autologinUser = vars.user;
    displayManager.autoLogin = {
      enable = true;
      inherit (vars) user;
    };
    xserver.displayManager.gdm.autoSuspend = false;
  };

  system.stateVersion = "24.05";

  hardware.enableRedistributableFirmware = true;
  networking.firewall.enable = false;

  users.users.${vars.user} = {
    isNormalUser = true;
    hashedPassword = "$7$CU..../....XLf//C9LnU4RhPpz8kVoe1$HIAtla6LnHT6BYsYqBbAXmWAJ1..nNBoRw4awirwQJ9";
    hashedPasswordFile = lib.mkForce null;
  };
}
