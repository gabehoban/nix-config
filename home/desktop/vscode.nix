{ inputs, pkgs, ... }:
let
  marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
  marketplace-release =
    inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace-release;
  editor = {
    "editor.bracketPairColorization.enabled" = true;
    "editor.bracketPairColorization.independentColorPoolPerBracketType" = true;
    "editor.cursorBlinking" = "smooth";
    "editor.cursorSmoothCaretAnimation" = "on";
    "editor.fontFamily" = "'Fira Code', 'Material Design Icons'";
    "editor.fontLigatures" = true;
    "editor.fontSize" = 12;
    "editor.fontWeight" = "500";
    "editor.formatOnSave" = true;
    "editor.guides.bracketPairs" = true;
    "editor.guides.indentation" = true;
    "editor.inlineSuggest.enabled" = true;
    "editor.linkedEditing" = true;
    "editor.lineHeight" = 22;
    "editor.lineNumbers" = "relative";
    "editor.minimap.enabled" = false;
    "editor.renderLineHighlight" = "all";
    "editor.semanticHighlighting.enabled" = true;
    "editor.showUnused" = true;
    "editor.smoothScrolling" = true;
    "editor.tabCompletion" = "on";
    "editor.tabSize" = 2;
    "editor.trimAutoWhitespace" = true;
    "indentRainbow.colors" = [
      "rgba(16, 16, 16, 0.10)"
      "rgba(16, 16, 16, 0.15)"
      "rgba(16, 16, 16, 0.20)"
      "rgba(16, 16, 16, 0.25)"
      "rgba(16, 16, 16, 0.30)"
      "rgba(16, 16, 16, 0.35)"
    ];
  };

  explorer = {
    "explorer.confirmDelete" = false;
    "explorer.confirmDragAndDrop" = false;
  };

  files = {
    "files.insertFinalNewline" = true;
    "files.trimTrailingWhitespace" = true;
  };

  telemetry = {
    "redhat.telemetry.enabled" = false;
    "telemetry.telemetryLevel" = "off";
  };

  terminal = {
    "terminal.integrated.fontSize" = 12;
    "terminal.integrated.smoothScrolling" = true;
  };

  window = {
    "window.autoDetectColorScheme" = true;
    "window.dialogStyle" = "native";
    "window.menuBarVisibility" = "toggle";
    "window.titleBarStyle" = "custom";
    "window.zoomLevel" = 1.5;
  };

  workbench = {
    "workbench.preferredDarkColorTheme" = "Nord";
    "workbench.colorTheme" = "Nord";
    # "workbench.iconTheme" = "catppuccin-macchiato";
    "workbench.panel.defaultLocation" = "right";
    "workbench.productIconTheme" = "icons-carbon";
    "workbench.sideBar.location" = "left";
    "workbench.startupEditor" = "none";
  };

  # Extension specific settings
  git = {
    "git.autofetch" = true;
    "git.enableCommitSigning" = true;
    "git.enableSmartCommit" = true;
  };

  path-intellisense = {
    "path-intellisense.autoSlashAfterDirectory" = true;
    "path-intellisense.autoTriggerNextSuggestion" = true;
    "path-intellisense.extensionOnImport" = true;
    "path-intellisense.showHiddenFiles" = true;
  };

  # Language specific settings
  # Formatter
  formatter = {
    "[css]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[html]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[java]"."editor.defaultFormatter" = "redhat.java";
    "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[json]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[jsonc]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
    "[python]"."editor.defaultFormatter" = "ms-python.black-formatter";
    "[scss]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
  };

  # Shell
  bash = {
    "bashIde.shellcheckPath" = "${pkgs.shellcheck}/bin/shellcheck";
    "shfmt.executablePath" = "${pkgs.shfmt}/bin/shfmt";
  };

  # Nix
  nix = {
    "nix.enableLanguageServer" = true;
    "nix.formatterPath" = [ "${pkgs.nixfmt-rfc-style}/bin/nixfmt" ];
    "nix.serverPath" = "${pkgs.nil}/bin/nil";
    "nix.serverSettings"."nil"."formatting"."command" = [ "${pkgs.nixfmt-rfc-style}/bin/nixfmt" ];
  };
in
{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    userSettings =
      {
        "extensions.autoCheckUpdates" = false;
        "extensions.ignoreRecommendations" = true;
        "update.mode" = "none";
      }
      # General settings
      // editor
      // explorer
      // files
      // telemetry
      // terminal
      // window
      // workbench
      # Extension specific settings
      // git
      // path-intellisense
      # Language specific settings
      // formatter
      // bash
      // nix;
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
