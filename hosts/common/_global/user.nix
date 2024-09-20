{
  config,
  pkgs,
  lib,
  ...
}:

let
  workstations = [ "pc_baymax" ];
  servers = [
    "rpi-casio"
    "rpi-sekio"
    "rpi-skyio"
  ];

  checkHostname = hostname: hostnameList: lib.elem hostname hostnameList;
in
{
  programs.zsh.enable = true;
  users.mutableUsers = false;
  users.users.gabehoban = {
    hashedPassword = "$7$CU..../....O.oYdMuk1KNKYyTH5NQI0.$osnkjWYRy8VEV2nKeTV4.jtBoX5qd0O7LvuJDbkSBU/";
    isNormalUser = true;
    uid = 1000;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGTRkzKhiDza+ClGzQcY8Tvsp5+2UhqVUg3Oie26ygy2 gabehoban@pc_baymax"
    ];
    shell = if checkHostname "${config.networking.hostName}" workstations then pkgs.zsh else pkgs.bash;
    extraGroups = [
      "wheel"
      "audio"
      "video"
      "plugdev"
      "dialout"
      "docker"
      "networkmanager"
      "adm"
    ];
  };
}
