{
  pkgs,
  lib,
  ...
}:
{
  # fail2ban firewall jail
  services.fail2ban = {
    enable = true;
    extraPackages = with pkgs; [
      nftables
      ipset
    ];

    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "100.77.0.0/16"
    ];

    banaction = "nftables-multiport";
    banaction-allports = lib.mkDefault "nftables-allport";

    maxretry = 7;
    bantime = "10m";
    bantime-increment = {
      enable = true;
      rndtime = "12m";
      overalljails = true;
      multipliers = "4 8 16 32 64 128 256 512 1024 2048";
      maxtime = "5000h";
    };

    daemonSettings = {
      Definition = {
        loglevel = "INFO";
        logtarget = "/var/log/fail2ban/fail2ban.log";
        socket = "/run/fail2ban/fail2ban.sock";
        pidfile = "/run/fail2ban/fail2ban.pid";
        dbfile = "/var/lib/fail2ban/fail2ban.sqlite3";
        dbpurageage = "1d";
      };
    };
  };
}
