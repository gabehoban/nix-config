{ lib, pkgs, ... }:
{
  # Create a bootable ISO image with bcachefs.
  boot = {
    kernelPackages = lib.mkOverride 0 pkgs.linuxPackages_latest;
    supportedFilesystems = [ "bcachefs" ];
  };
  environment.systemPackages = with pkgs; [
    bcachefs-tools
    keyutils
  ];
}
