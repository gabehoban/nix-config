{
  # Many distros enable this by default
  zramSwap.enable = true;
  zramSwap.memoryPercent = 100;
  boot.kernel.sysctl."vm.swappiness" = 180;
  boot.kernel.sysctl."vm.page-cluster" = 0;
  boot.kernel.sysctl."vm.dirty_background_bytes" = 128 * 1024 * 1024;
  boot.kernel.sysctl."vm.dirty_bytes" = 64 * 1024 * 1024;
  boot.kernel.sysctl."vm.vfs_cache_pressure" = 500;
  boot.kernel.sysctl."vm.watermark_boost_factor" = 0;
  boot.kernel.sysctl."vm.watermark_scale_factor" = 125;
}
