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
}
