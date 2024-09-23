{ pkgs, vars, ... }:
{
  programs.zsh = {
    enable = true;
  };
  users.mutableUsers = false;
  users.users.${vars.username} = {
    hashedPassword = "$7$CU..../....O.oYdMuk1KNKYyTH5NQI0.$osnkjWYRy8VEV2nKeTV4.jtBoX5qd0O7LvuJDbkSBU/";
    isNormalUser = true;
    uid = 1000;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGTRkzKhiDza+ClGzQcY8Tvsp5+2UhqVUg3Oie26ygy2 gabehoban@baymax"
    ];
    shell = pkgs.zsh;
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
