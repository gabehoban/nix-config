{ outputs, vars, ... }:
{
  home = {
    username = "${vars.username}";
    homeDirectory = "/home/${vars.username}";

    shellAliases = {
      # nix specific aliases
      cleanup = "sudo nix-collect-garbage --delete-older-than 3d && nix-collect-garbage -d";
      bloat = "nix path-info -Sh /run/current-system";
      repair = "nix-store --verify --check-contents --repair";

      sha = "shasum -a 256"; # Test checksum
    };
  };

  nixpkgs = {
    overlays = [ outputs.overlays.unstable-packages ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
