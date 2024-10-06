{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    extest.enable = true;
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  boot.kernel.sysctl = {
    "kernel.sched_cfs_bandwidth_slice_us" = 3000;
    "net.ipv4.tcp_fin_timeout" = 5;
    "vm.max_map_count" = 2147483642;
  };
  environment.sessionVariables.WINEDEBUG = "-all";

  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      gpu = {
        amd_performance_level = "high";
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
      };
      general.renice = 10;
    };
  };
  users.users.gabehoban.extraGroups = [ "gamemode" ];
}
