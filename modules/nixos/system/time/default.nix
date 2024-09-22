{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.openntpd ];

  networking.timeServers = [
    "10.32.40.51"
    "10.32.40.52"
  ];

  services.openntpd = {
    enable = true;
    extraConfig = ''
      listen on 127.0.0.1
      listen on ::1
    '';
  };

  time.timeZone = "America/New_York";
}
