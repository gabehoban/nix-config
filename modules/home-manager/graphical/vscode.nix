{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = true;

    extensions =
      (with pkgs.vscode-extensions; [
        # Themes
        catppuccin.catppuccin-vsc

        # Misc Extensions
        christian-kohler.path-intellisense
        ryu1kn.partial-diff
        github.vscode-github-actions
        github.vscode-pull-request-github

        # Language support
        hashicorp.terraform
        jnoortheen.nix-ide
        ms-azuretools.vscode-docker
        ms-python.python
        redhat.vscode-yaml
      ])
      ++ (with pkgs.vscode-marketplace; [
        thang-nm.catppuccin-perfect-icons
        mrmlnc.vscode-json5
        coolbear.systemd-unit-file
        codezombiech.gitignore
        bmalehorn.shell-syntax
      ]);

    userSettings = {
      "catppuccin.accentColor" = "sky";
      "workbench.colorTheme" = "Catppuccin Frappé";
      "workbench.iconTheme" = "catppuccin-perfect-frappe";
      "explorer.confirmDragAndDrop" = false;

      "editor.bracketPairColorization.enabled" = true;
      "editor.fontFamily" = "'Monaspace Krypton','Font Awesome 6 Free Solid'";
      "editor.fontLigatures" = "'calt', 'liga', 'dlig', 'ss01', 'ss02', 'ss03', 'ss06'";
      "editor.guides.bracketPairs" = true;
      "editor.guides.bracketPairsHorizontal" = true;
      "editor.guides.highlightActiveBracketPair" = true;

      "files.autoSave" = "onFocusChange";
      "files.eol" = "\n";
      "files.insertFinalNewline" = true;
      "files.trimFinalNewlines" = true;
      "files.trimTrailingWhitespace" = true;
      "git.confirmSync" = false;
    };
  };
}
