{ config, inputs, lib, pkgs, impermanence, ... }:
{
    config = {
        environment.persistence."/persist" = {
            directories = [
                "/etc/NetworkManager/system-connections"
                "/etc/ssh"
                "/etc/nix/inputs"

                "/var/log"
                "/var/lib"
                "/root"
            ];
            files = [
                "/etc/machine-id"
                "/etc/nix/id_rsa"
            ];

            users.gabehoban = {
                directories = [
                "DevOps"
                "Downloads"
                "Documents"
                "nix-config"
                {
                    directory = ".gnupg";
                    mode = "0700";
                }
                {
                    directory = ".ssh";
                    mode = "0700";
                }
                ".config/pulse"
                ".pki"
                ".steam"
                # vscode
                ".vscode"
                ".vscode-insiders"
                ".config/Code/User"
                ".config/Code - Insiders/User"
                # 1Password
                ".config/1Password"
                # Maestral - Dropbox Client
                ".config/maestral"
                # browsers
                ".mozilla"          
                ];
            };
        };
    };
}