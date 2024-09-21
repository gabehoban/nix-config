{
  config,
  pkgs,
  outputs,
  ...
}:
{

  imports = [
    ./global
    ./optional/terminator.nix
    ./optional/zsh.nix
    ./optional/security-tooling.nix
  ];

  home.packages = with pkgs; [ unstable.jellyfin-media-player ];

  nixpkgs = {
    overlays = [ outputs.overlays.unstable-packages ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

}
