{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.syscfg.graphics;
in
{
  options.syscfg.graphics = {
    nvidia = lib.mkEnableOption "NVIDIA GPU Configuration";
  };
  config = lib.mkIf cfg.nvidia {
    services.xserver.videoDrivers = [ "nvidia" ];

    boot.kernelParams = [
      "nvidia-drm.fbdev=1"
    ];

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          nvidia-vaapi-driver
          vaapiVdpau
          libvdpau-va-gl
        ];
      };
      nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.latest;
        open = false;
        modesetting.enable = true;
      };

      nvidia-container-toolkit = {
        enable = true;
      };
    };

    environment = {
      sessionVariables = {
        NVD_BACKEND = "direct";
        GBM_BACKEND = "nvidia-drm";
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };
      systemPackages = with pkgs; [
        cudatoolkit
        egl-wayland
        glxinfo
        libva
        libva-utils
        vulkan-loader
        vulkan-tools
      ];
    };
    systemd.sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };
}
