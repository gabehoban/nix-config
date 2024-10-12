{ lib, inputs, ... }:
{
  imports = [
    ./blocky.nix
    ./hydra.nix
    ./nginx.nix
    ./step-ca.nix
  ];
}
