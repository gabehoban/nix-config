{ vars, ... }:
{
  config = {
    environment.persistence."/persist" = {
      directories = [
        "/etc/NetworkManager/system-connections"
        "/var/lib/chrony"
        "/var/lib/fail2ban"
        "/var/lib/nixos"
        "/var/lib/sops-nix"
        "/var/lib/tailscale"
        "/var/log"
        {
          directory = "/var/lib/private";
          mode = "0700";
        }
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
      users."${vars.user}" = {
        directories = [
          ".1Password"
          ".config/sops"
          ".config/nix"
          ".local/share/zsh"
          ".local/share/direnv"
          ".mozilla"
          "desktop"
          "documents"
          "downloads"
          "pictures"
          {
            directory = ".ssh";
            mode = "0700";
          }
        ];
      };
    };
  };
}
