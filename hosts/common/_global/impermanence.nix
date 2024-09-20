{ lib, inputs, config, ... }: {
  # Taken from Misterio77's config

  environment.persistence = {
    "/persist" = {
    hideMounts = true;
      directories = [
        "/var/lib/systemd"
        "/var/lib/NetworkManager"
        "/var/lib/nixos"
        "/var/lib/sops-nix"
        "/var/lib/libvirt"
        "/var/log"
        "/etc/cups"
        "/etc/NetworkManager"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };
  };
  programs.fuse.userAllowOther = true;

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';
}