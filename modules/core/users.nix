{
  config,
  inputs,
  pkgs,
  user,
  ...
}:
{
  programs.fish.enable = true;

  #age.secrets.user-password.rekeyFile = "${inputs.self.outPath}/secrets/user-password.age";
  users.users = {
    root.hashedPassword = "!";
    ${user} = {
      isNormalUser = true;
      shell = pkgs.fish;
      hashedPassword = !!todo;
      #hashedPasswordFile = config.age.secrets.user-password.path;
      extraGroups = [
        "networkmanager"
        "wheel"
        "disk"
        "video"
        "input"
        "media"
      ];
    };
  };
}
