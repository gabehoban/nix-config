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
        "/var/lib/attic-watch-store"
        "/var/log"
        {
          directory = "/var/lib/private";
          mode = "0700";
        }
        {
          directory = "/var/lib/acme";
          user = "acme";
          group = "nginx";
        }
        {
          directory = "/var/lib/hydra";
          user = "hydra";
          group = "hydra";
        }
        {
          directory = "/var/lib/postgresql";
          user = "postgres";
          group = "postgres";
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
        files = [
          ".config/zsh/.zsh_history"
        ];
      };
    };
  };
}
