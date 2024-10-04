{ config, ... }:
{
  networking = {
    hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);
    useDHCP = false;
    useNetworkd = true;
    usePredictableInterfaceNames = true;
    nameservers = [
      "10.32.40.51"
      "10.32.40.52"
    ];
    search = [
      "lab4.cc"
      "gabehoban.lab4.cc"
    ];
  };
}
