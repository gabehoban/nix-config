{ lib, inputs, ... }:
{
  imports = [
    ./blocky.nix
    ./headscale.nix
    ./hydra.nix
    ./nginx.nix
    ./step-ca.nix
  ];
  options.syscfg.server = {
    enable = lib.mkOption {
      description = "Configure with server services";
      type = lib.types.bool;
      default = false;
    };
  };
}
