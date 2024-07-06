{ pkgs, ... }:
{
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = with pkgs; [
    (pkgs.writeShellApplication {
      name = "nixfmt-plus";
      runtimeInputs = with pkgs; [
        deadnix
        nixfmt-rfc-style
        statix
      ];
      text = ''
        set -x
        deadnix --edit
        statix fix
        nixfmt .
      '';
    })
  ];
}
