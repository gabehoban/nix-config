# syscfgOS: My Secure NixOS Configuration

![NixOS Flake](https://img.shields.io/badge/NixOS-flake-blue?logo=nixos)
![secrets sops-nix](https://img.shields.io/badge/secrets-sops--nix-blue)

## Goal

syscfgOS should be a secure, minimal, and modular NixOS framework tailored to my
use case.

### Features

- Properly configured desktop environment with Gnome and useful desktop apps.
- Neovim (NixVim) configured with LSP, telescope, and other QoL plugins.
- Secrets management with `sops-nix`.
- Browser configured with uBlock Origin, DuckDuckGo, and other extensions.
- Shell configured with modern tools & improvements, such as nix-direnv,
  zoxide, eza, zsh-autocomplete, ls-colors, useful aliases, and more.
- Tailscale with auto-authentication (using sops-nix).
- Home Lab setup
  - Logging and monitoring using Grafana
  - AdGuard Home configured
  - Media server
- Web server for my personal website and other services.
- "Server Mode" specialisation for laptops.
- System hardening for kernel, web server, etc.

## Hosts

Systems managed by this flake.

| Name      | System             | CPU        | RAM  | GPU                     | Role | OS   | State |
| --------- | ------------------ | ---------- | ---- | ----------------------- | ---- | ---- | ----- |
| `baymax`  | Desktop PC         | i9-12900KF | 64GB | NVIDIA GeForce RTX 3060 | 💻️   | ❄️    | ✅    |
| `macbook` | MacBook Pro        | M2 Max     | 64GB | M2 Max                  | 💻️   |     | 🚧    |
| `srvio`   | Dell OptiPlex 7040 | i5-6500    | 32GB | Intel HD Graphics 530   | 💻️   | ❄️    | ✅    |
| `vpsio`   | Hetzner VPS CPX31  | 4 vCPU     | 8GB  | None                    | ☁️    | ❄️    | ✅    |
| `casio`   | RPI 4B+ Rev 1.5    | BCM2711    | 8GB  | None                    | ☁️    | ❄️    | ✅    |
| `sekio`   | RPI 4B+ Rev 1.5    | BCM2711    | 8GB  | None                    | ☁️    | ❄️    | ✅    |

Rebuilding a system:

```
sudo nixos-rebuild switch --flake github:gabehoban/nix-config#<hostname> --refresh
```

## Bootstrapping

### x86 Machine

Build and flash the installer image:

```
nix build github:gabehoban/nix-config#installer
sudo cp ./result/iso/*.iso /dev/sdX
```

Alternatively, this ISO works with [Ventoy].

Then you may finally install with:

```
sudo nixos-install --root /mnt --flake github:gabehoban/nix-config#<host>
```

### Raspberry Pi

Build and flash the SD card image:

```
nix build github:gabehoban/nix-config#packages.aarch64-linux.rpi4-bootstrap
sudo cp ./result/*.img /dev/mmcblkX
```

When booted, the image should auto-resize to fill the card. You should be able
to SSH into the device using SSH key.

Once a new host is configured for this machine, simply rebuild the system
directly from the GitHub repository.

Don't forget to add the age public key into `.sops.yaml` and update the keys.

## macOS Setup & Usage

Install Nix using the [Determinate Systems installer](https://zero-to-nix.com/start/install).

```
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Then run the following (without sudo):

```
darwin-rebuild switch --flake github:gabehoban/nix-config#macbook --refresh
```
# Credits

Other dotfiles that I learned / copy from:

- Nix Flakes
  - [humaidq/dotfiles](https://github.com/humaidq/dotfiles): General flake / files structure
  - [koenw/stratum](https://github.com/koenw/stratum): RPI Stratum 1 NTP Server
