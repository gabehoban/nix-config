{
  inputs,
  user,
  pkgs,
  ...
}:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
    overlays = [
      inputs.attic.overlays.default
    ];
  };

  programs.nh = {
    enable = true;
    flake = "/home/${user}/nix-config";
    clean = {
      enable = true;
      extraArgs = "--keep-since 3d --keep 3";
    };
  };

  nix = {
    optimise = {
      automatic = true;
    };

    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";

    settings = {
      experimental-features = [
        "flakes"
        "nix-command"
        "recursive-nix"
        "ca-derivations"
        "auto-allocate-uids"
        "cgroups"
        "repl-flake"
        "no-url-literals"
        "dynamic-derivations"
      ];
      warn-dirty = false;
      builders-use-substitutes = true;
      keep-outputs = true;
      keep-derivations = true;
      use-cgroups = pkgs.stdenv.isLinux;
      allowed-users = [ "@wheel" ];
      trusted-users = [
        "root"
        "@wheel"
      ];
      substituters = [
        "https://cache.nixos.org?priority=10"
        "https://cache.lab4.cc/main"
        "https://nix-community.cachix.org"
        "https://nyx.chaotic.cx"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "main:swo2iC3lOlH6MAGDdH8F3YglXfxMCEd9oksQg++QbS8="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      ];
      system-features = [
        "nixos-test"
        "kvm"
        "recursive-nix"
        "big-parallel"
      ];
    };
  };
}
