{ inputs, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    histSize = 100000;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
    };
  };
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = true;
      dialect = "us";
      show_preview = true;
      style = "compact";
      sync_frequency = "1h";
      sync_address = "https://atuin.labrats.cc";
      update_check = false;
    };
  };

  users.defaultUserShell = pkgs.zsh;
}
