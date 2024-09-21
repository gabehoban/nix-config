{ inputs, pkgs, ... }:
let
  marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
  marketplace-release =
    inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace-release;
in
{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    extensions =
      (with pkgs.vscode-extensions; [
        github.vscode-github-actions
        github.vscode-pull-request-github
      ])
      ++ (with marketplace; [
        arcticicestudio.nord-visual-studio-code
        antfu.icons-carbon
        christian-kohler.path-intellisense
        editorconfig.editorconfig
        esbenp.prettier-vscode
        jnoortheen.nix-ide
        mads-hartmann.bash-ide-vscode
        mikestead.dotenv
        mkhl.direnv
        mkhl.shfmt
        ms-python.black-formatter
        ms-python.isort
        ms-python.pylint
        ms-python.python
        ms-python.vscode-pylance
        naumovs.color-highlight
        oderwat.indent-rainbow
        redhat.java
        redhat.vscode-yaml
        usernamehw.errorlens
        yzhang.markdown-all-in-one
      ])
      ++ (with marketplace-release; [ eamodio.gitlens ]);
  };
}
