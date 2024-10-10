_: {
  # nix configuration
  # reference: https://daiderd.com/nix-darwin/manual/index.html#sec-options

  imports = [
    ../../modules/profiles/macbook.nix
  ];
  programs.zsh.enable = true;

  services.nix-daemon.enable = true;

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 4;
}
