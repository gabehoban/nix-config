{ pkgs, ... }:
{
  home.packages = [ pkgs.neovim ];

  # Use Neovim as the editor for git commit messages
  programs.git.extraConfig.core.editor = "nvim";

  # Set Neovim as the default app for text editing and manual pages
  home.sessionVariables = {
    EDITOR = "nvim";
    MANPAGER = "nvim -c 'set ft=man bt=nowrite noswapfile nobk shada=\\\"NONE\\\" ro noma' +Man! -o -";
  };

  programs.zsh = {
    shellAliases = {
      vi = "nvim";
      vim = "nvim";
    };
  };
}
