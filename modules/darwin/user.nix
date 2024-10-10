{ pkgs, ... }:
{
  # user configuration
  # nix-darwin options documentation: https://daiderd.com/nix-darwin/manual/index.html#sec-options

  networking = {
    computerName = "macbook";
    dns = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    knownNetworkServices = [
      "Wi-Fi"
      "Thunderbolt Bridge"
    ]; # required when specifying dns
  };

  # define user
  users.users."gabehoban" = {
    shell = pkgs.zsh; # default user shell
    home = "/Users/gabehoban";
    createHome = true; # create home directory structure
  };
}
