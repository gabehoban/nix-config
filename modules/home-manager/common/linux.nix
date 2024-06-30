{ pkgs, ... }: {
  home.packages = with pkgs; [
    vscode

    # Misc
    tldr
    cowsay
    gnupg
    gnumake

    # search for files by its content, replacement of grep
    ripgrep

    # A fast and polyglot tool for code searching, linting, rewriting at large scale
    # supported languages: only some mainstream languages currently(do not support nix/nginx/yaml/toml/...)
    ast-grep

    sad # CLI search and replace, just like sed, but with diff preview.
    yq-go # yaml processor https://github.com/mikefarah/yq
    just # a command runner like make, but simpler
    delta # A viewer for git and diff output
    lazygit # Git terminal UI.
    gping # ping, but with a graph(TUI)
    doggo # DNS client for humans
    duf # Disk Usage/Free Utility - a better 'df' alternative
    du-dust # A more intuitive version of `du` in rust
    gdu # disk usage analyzer(replacement of `du`)

    # nix related
    nix-output-monitor
    hydra-check # check hydra(nix's build farm) for the build status of a package
    nix-index # A small utility to index nix store paths
    nix-init # generate nix derivation from url
    nix-melt # A TUI flake.lock viewer
    nix-tree # A TUI to visualize the dependency graph of a nix derivation

    # productivity
    croc # File transfer between computers securely and easily
    ncdu # analyzer your disk usage Interactively, via TUI(replacement of `du`)
  ];

  programs.neovim = {
    enable = true;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 60;
    maxCacheTtl = 120;
  };
}
