{ pkgs, ... }:
let
  # General settings
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
  programs.vscode.userSettings =
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
}
