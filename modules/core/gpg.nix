_: {
  programs.gnupg.agent = {
    enable = true;
    enableExtraSocket = true;
    enableSSHSupport = true;
    settings = {
      default-cache-ttl = 34560000;
      max-cache-ttl = 34560000;
    };
  };
}
