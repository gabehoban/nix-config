{
  config,
  inputs,
  lib,
  ...
}:
{
  age.rekey = {
    hostPubkey = builtins.readFile "${inputs.self.outPath}/hosts/${config.networking.hostName}/host.pub";
    masterIdentities = [ ../../secrets/yk1-nix-rage.pub ];
    storageMode = "local";
    localStorageDir = "${inputs.self.outPath}/secrets/rekeyed/${config.networking.hostName}";
  };
  system.activationScripts = lib.mkIf (config.age.secrets != { }) {
    removeAgenixLink.text = "[[ ! -L /run/agenix ]] && [[ -d /run/agenix ]] && rm -rf /run/agenix";
    agenixNewGeneration.deps = [ "removeAgenixLink" ];
  };
}
