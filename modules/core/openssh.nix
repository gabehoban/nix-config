{
  inputs,
  lib,
  user,
  ...
}:
{
  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = lib.mkForce false;
      PubkeyAuthentication = lib.mkForce true;
      StreamLocalBindUnlink = true;
      UseDns = false;
      X11Forwarding = false;
      KexAlgorithms = [
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group16-sha512"
        "diffie-hellman-group18-sha512"
        "sntrup761x25519-sha512@openssh.com"
      ];
    };
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  users.users.${user}.openssh.authorizedKeys.keyFiles = [ inputs.ssh-keys.outPath ];
  users.users.root.openssh.authorizedKeys.keyFiles = [ inputs.ssh-keys.outPath ];
}
