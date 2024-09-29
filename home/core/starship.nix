_: {
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      direnv.disabled = false;
      directory = {
        truncation_symbol = "…/";
        truncate_to_repo = false;
      };
      git_metrics.disabled = false;
      localip = {
        ssh_only = true;
        disabled = false;
      };
      memory_usage.disabled = false;
      os.disabled = false;
      shell.disabled = false;
      shlvl.disabled = false;
      status.disabled = false;
      time.disabled = false;
      continuation_prompt = "▶▶ ";
    };
  };
}
