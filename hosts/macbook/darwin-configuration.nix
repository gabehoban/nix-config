{ pkgs, inputs, ... }:
let
  inherit (inputs) home-manager self;
in
{
  imports =
    [ home-manager.darwinModules.home-manager ]
    ++ (with self.nixosModules; [
      nix
      nixpkgs
      hm
      packages
    ]);

  fonts.packages = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    pkgs.monaspace
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.zsh.enable = true;

  users.users.gabehoban.home = "/Users/gabehoban";
  home-manager.users.gabehoban = import ./home.nix;

  services.nix-daemon.enable = true;
  system.stateVersion = 4;
}
