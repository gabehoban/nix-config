{ user, ... }:
{
  imports = [
    ../../core
  ];
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "24.05";
    extraOutputsToInstall = [
      "doc"
      "devdoc"
    ];
  };
}
