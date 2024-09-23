{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    tpm2-tss
    tpm2-tools
  ];
  security.tpm2 = {
    enable = true;
  };
}
