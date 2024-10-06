_: {
  security = {
    allowSimultaneousMultithreading = true;
    allowUserNamespaces = true;
    forcePageTableIsolation = true;
    lockKernelModules = false;
    polkit.enable = true;
    protectKernelImage = true;
    rtkit.enable = true;
  };

  services.endlessh-go = {
    enable = true;
    port = 22;
    prometheus = {
      enable = true;
      port = 2112;
    };
    openFirewall = true;
  };
}
