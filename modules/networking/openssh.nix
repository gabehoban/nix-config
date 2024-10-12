# Original code by NotAShelf - https://github.com/notashelf/nyx
#
# SSH - Server Setup (openssh, fail2ban, ssh-agent)
#
{
  config,
  lib,
  vars,
  ...
}:
let
  cfg = config.syscfg.openssh;
  sshKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqFRwe/auSdigp5l+XmgIABl8rIIFuwBh9I2WNRpIfYKYJRyKkLbYZO3Z56lCxqjJkTUIIdw+hsUvR3A71HVRnRlx05pMQ9IMn6XSrx+AQVXs/hBFNijQsmCVUMebop2kW1WZUfIgMg4+5L9VQPL+pX6ARKuXSf8Gv2Qn+rInpY1rYE9DesezjzA2Cljr3Pii1JlmqYDDLS2HnZ10FhJfutqWPUR9RnX4HcVXKcxE9rgHzjGSyNkaFVX2HG8SafePyABacoajNQVORn7PHD9RLUeQ+qM8IIvAVxig2JPt36AnWjakSumwgyf/NjrbjJTMlacN3zqresfcsa3+HdGki86QRbZ2bNRurrBbevxxzgQggjW0506drw49sN/y78BGuYjZJjQW3C7TPHaLpPBKMIEFz64vuwATZiLpSb/mfGqXvpXb9Yl91qYbOy6GdXOO54EMb4zM6pQn1n3h6uaneJ/ZjM2GarbcGE5d/Nxw3AsS7gVUBAXrkbHdmJnXzoZWKO1DGjx7fGnHHvyKZN997BEzGpTMIRbF7g2S0RLVVjVYmLJNpCPGxkWACeJN+CXYof/Yl1adeCmQVLagtO8HwsBQLRO2CJwveUwnNRK3WVOOM8DK+u5ROgg1XJO7ngXnP3HKql6ju0kYRpwlRj/dZNrsJh7tYDgXr/9B8I/9Q4w== cardno:17_077_465"
  ];
in
{
  options.syscfg.openssh.enable = lib.mkOption {
    description = "Configure the OpenSSH service for remote connections.";
    type = lib.types.bool;
    default = true;
  };
  config = lib.mkIf cfg.enable {
    services = {
      openssh = {
        # enable openssh
        enable = true;
        openFirewall = true; # the ssh port(s) should be automatically passed to the firewall's allowedTCPports
        ports = [ 30 ]; # the port(s) openssh daemon should listen on
        settings = {
          PermitRootLogin = lib.mkForce "yes";

          # no password auth
          # force publickey authentication only
          PasswordAuthentication = lib.mkForce false;
          AuthenticationMethods = "publickey";
          PubkeyAuthentication = "yes";
          ChallengeResponseAuthentication = "no";
          UsePAM = false;

          # remove sockets as they get stale
          # this will unbind gnupg sockets if they exists
          StreamLocalBindUnlink = "yes";

          KbdInteractiveAuthentication = lib.mkDefault false;
          UseDns = false; # no
          X11Forwarding = false; # ew xorg

          # key exchange algorithms recommended by `nixpkgs#ssh-audit`
          KexAlgorithms = [
            "curve25519-sha256"
            "curve25519-sha256@libssh.org"
            "diffie-hellman-group16-sha512"
            "diffie-hellman-group18-sha512"
            "diffie-hellman-group-exchange-sha256"
            "sntrup761x25519-sha512@openssh.com"
          ];

          # message authentication code algorithms recommended by `nixpkgs#ssh-audit`
          Macs = [
            "hmac-sha2-512-etm@openssh.com"
            "hmac-sha2-256-etm@openssh.com"
            "umac-128-etm@openssh.com"
          ];

          # kick out inactive sessions
          ClientAliveCountMax = 5;
          ClientAliveInterval = 60;

          # max auth attempts
          MaxAuthTries = 3;
        };

        hostKeys = lib.mkDefault [
          {
            bits = 4096;
            path = "/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];
      };
      fail2ban.jails = {
        sshd = {
          settings = {
            enabled = true;
            filter = "sshd[mode=aggressive]";
            port = lib.concatStringsSep "," (map toString config.services.openssh.ports);
          };
        };
      };
    };

    programs.ssh =
      let
        hosts = [
          "baymax"
          "vpsio"
          "casio"
          "sekio"
          "skyio"
        ];

        # generate the ssh config for the hosts
        mkHostConfig = hostname: ''
          # Configuration for ${hostname}
          Host ${hostname}
            HostName ${hostname}
          Port ${toString (lib.elemAt config.services.openssh.ports 0)}
            StrictHostKeyChecking=accept-new
        '';

        hostConfig = lib.concatStringsSep "\n" (map mkHostConfig hosts);
      in
      {
        startAgent = false;
        extraConfig = ''
          ${hostConfig}
        '';

        # ship github/gitlab/sourcehut host keys to avoid MiM (man in the middle) attacks
        knownHosts = lib.mapAttrs (_: lib.mkForce) {
          github-rsa = {
            hostNames = [ "github.com" ];
            publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
          };

          github-ed25519 = {
            hostNames = [ "github.com" ];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
          };

          gitlab-rsa = {
            hostNames = [ "gitlab.com" ];
            publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsj2bNKTBSpIYDEGk9KxsGh3mySTRgMtXL583qmBpzeQ+jqCMRgBqB98u3z++J1sKlXHWfM9dyhSevkMwSbhoR8XIq/U0tCNyokEi/ueaBMCvbcTHhO7FcwzY92WK4Yt0aGROY5qX2UKSeOvuP4D6TPqKF1onrSzH9bx9XUf2lEdWT/ia1NEKjunUqu1xOB/StKDHMoX4/OKyIzuS0q/T1zOATthvasJFoPrAjkohTyaDUz2LN5JoH839hViyEG82yB+MjcFV5MU3N1l1QL3cVUCh93xSaua1N85qivl+siMkPGbO5xR/En4iEY6K2XPASUEMaieWVNTRCtJ4S8H+9";
          };
          gitlab-ed25519 = {
            hostNames = [ "gitlab.com" ];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
          };

          sourcehut-rsa = {
            hostNames = [ "git.sr.ht" ];
            publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZ+l/lvYmaeOAPeijHL8d4794Am0MOvmXPyvHTtrqvgmvCJB8pen/qkQX2S1fgl9VkMGSNxbp7NF7HmKgs5ajTGV9mB5A5zq+161lcp5+f1qmn3Dp1MWKp/AzejWXKW+dwPBd3kkudDBA1fa3uK6g1gK5nLw3qcuv/V4emX9zv3P2ZNlq9XRvBxGY2KzaCyCXVkL48RVTTJJnYbVdRuq8/jQkDRA8lHvGvKI+jqnljmZi2aIrK9OGT2gkCtfyTw2GvNDV6aZ0bEza7nDLU/I+xmByAOO79R1Uk4EYCvSc1WXDZqhiuO2sZRmVxa0pQSBDn1DB3rpvqPYW+UvKB3SOz";
          };

          sourcehut-ed25519 = {
            hostNames = [ "git.sr.ht" ];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
          };
        };
      };
    users.users.${vars.user}.openssh.authorizedKeys.keys = sshKeys;
    users.users.root.openssh.authorizedKeys.keys = sshKeys;

    environment.persistence."/persist" = {
      hideMounts = true;
      files = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
      users."${vars.user}" = {
        directories = [
          {
            directory = ".ssh";
            mode = "0700";
          }
        ];
      };
    };
  };
}
