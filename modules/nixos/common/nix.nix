{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  flakeInputs = lib.filterAttrs (_: input: input ? "_type" && input._type == "flake") inputs;
  sudoGroup = if isDarwin then "@admin" else "@wheel";
in
{
  nixpkgs = {
    config.allowUnfree = true;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      sudoGroup
    ];
    auto-optimise-store = !isDarwin;
    substituters = [
      "https://nix-community.cachix.org"
      "https://gabehoban.cachix.org"
      "https://cuda-maintainers.cachix.org"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "gabehoban.cachix.org-1:BIoL9Y7AtTdEBgEUW0iMg49k0iHBlzFr/lMGtp+6K9U="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
    builders-use-substitutes = true;
  };
  nix.registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
  nix.nixPath = lib.mapAttrsToList (name: flake: "${name}=${flake}") flakeInputs;

  nix.gc = {
    automatic = true;
    dates = lib.mkIf (!isDarwin) "weekly";
    options = "--delete-older-than 14d";
  };
}
