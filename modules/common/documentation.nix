{ lib, ... }:
{
  # faster rebuilding
  documentation = lib.mapAttrs (_: lib.mkForce) {
    enable = false;
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
    man.enable = false;
  };
}
