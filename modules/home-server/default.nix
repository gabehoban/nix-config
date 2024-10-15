{ lib, ... }:
{
  imports = [
    ./blocky.nix
    ./grafana.nix
    ./headscale.nix
    ./hydra.nix
    ./nginx.nix
    ./oauth2.nix
    ./prometheus.nix
  ];
  options.syscfg.server = {
    enable = lib.mkOption {
      description = "Configure with server services";
      type = lib.types.bool;
      default = false;
    };
  };
}
