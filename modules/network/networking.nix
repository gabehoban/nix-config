{ config, ... }:
{
  networking = {
    hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);
    useDHCP = false;
    useNetworkd = true;
    usePredictableInterfaceNames = true;
    extraHosts = ''
      5.161.231.127 headscale.labrats.cc
    '';

    nameservers = [
      "9.9.9.9"
    ];
    search = [
      "lab4.cc"
      "gabehoban.lab4.cc"
    ];
  };
}
