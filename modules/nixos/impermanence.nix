{
  inputs,
  lib,
  user,
  ...
}:
let
  inherit (lib) forEach;
in
{
  imports = [ inputs.impermanence.nixosModule ];

  environment.persistence."/persist" = {
    hideMounts = true;
    directories =
      [
        "/tmp"
        "/var/log"
        "/var/tmp"
        "/var/db/sudo"
        "/var/cache/apparmore"
      ]
      ++ forEach [
        "NetworkManager"
        "nix"
        "ssh"
        "secureboot"
      ] (x: "/etc/${x}")
      ++ forEach [
        "bluetooth"
        "docker"
        "libvirt"
        "nixos"
        "pipewire"
        "tailscale"
      ] (x: "/var/lib/${x}")
      ++ forEach [
        "coredump"
        "timers"
      ] (x: "/var/lib/systemd/${x}");
    files = [ "/etc/machine-id" ];
    users.${user} = {
      directories =
        [
          ".1Password"
          ".steam"
          ".mozilla"
          ".vscode"
          ".kube"
          "download"
          "music"
          "repos"
          "documents"
          "pictures"
          "videos"
          "sync"
          "other"
          "nix-config"
        ]
        ++ forEach [
          "1Password"
          "dconf"
          "rclone"
          "Yubico"
          "syncthing"
          "fish"
          "vesktop"
          "obs-studio"
          "gh"
        ] (x: ".config/${x}")
        ++ forEach [ "nix" ] (x: ".cache/${x}")
        ++ forEach [
          "Steam"
          "fish"
          "direnv"
        ] (x: ".local/share/${x}")
        ++ [
          {
            directory = ".ssh";
            mode = "0700";
          }
          {
            directory = ".gnupg";
            mode = "0700";
          }
          {
            directory = ".local/share/keyrings";
            mode = "0700";
          }
        ];
    };
  };

  systemd.tmpfiles.rules = [
    "L /var/lib/NetworkManager/secret_key - - - - /persist/var/lib/NetworkManager/secret_key"
    "L /var/lib/NetworkManager/seen-bssids - - - - /persist/var/lib/NetworkManager/seen-bssids"
    "L /var/lib/NetworkManager/timestamps - - - - /persist/var/lib/NetworkManager/timestamps"
  ];
}
