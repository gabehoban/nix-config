{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ inputs.hardware.nixosModules.common-gpu-nvidia-nonprime ];

  boot.blacklistedKernelModules = [ "nouveau" ];

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    deviceSection = ''
      Option "Coolbits" "28"
    '';
  };

  environment.systemPackages = with pkgs; [
    # nvidia packages
    nvfancontrol
    nvtopPackages.nvidia
    # mesa
    mesa
    libGL
    libglvnd
    libva
    libva-utils
    libvdpau-va-gl
    # vulkan
    vdpauinfo
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    vulkan-extension-layer
    # cuda
    cudaPackages.cudatoolkit
  ];

  hardware = {
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      modesetting.enable = lib.mkDefault true;

      powerManagement = {
        enable = lib.mkDefault false;
        finegrained = lib.mkDefault false;
      };

      open = lib.mkDefault false;
      nvidiaSettings = false;
    };

    nvidia-container-toolkit.enable = true;

    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    graphics = {
      extraPackages = with pkgs; [ nvidia-vaapi-driver ];
      extraPackages32 = with pkgs.pkgsi686Linux; [ nvidia-vaapi-driver ];
    };
  };
}
