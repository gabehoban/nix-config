{ desktop, lib, pkgs, ... }:
let
  isWorkstation = if (desktop != null) then true else false;
in
{
  environment.systemPackages = with pkgs.unstable; [
    oterm
  ];

  services.ollama = {
    enable = true;
    acceleration = "cuda";
    environmentVariables = {
      HOME = "/var/lib/ollama";
      OLLAMA_MODELS = "/var/lib/ollama/models";
      OLLAMA_HOST = "0.0.0.0:11434";
    };
  };
}
