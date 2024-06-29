{ pkgs
, inputs
, ...
}:
let
  inherit (inputs) self agenix;
in
{
  imports = [ agenix.homeManagerModules.age ] ++ (with self.homeManagerModules; [
    home
    wezterm
    vscode
  ]);

  # Darwin doesn't support services.gpg-agent
  # https://github.com/nix-community/home-manager/issues/91
  home.file.".gnupg/gpg-agent.conf".text =
    let
      inherit (pkgs) pinentry_mac;
    in
    ''
      enable-ssh-support
      ttyname $GPG_TTY
      default-cache-ttl 60
      max-cache-ttl 120
      pinentry-program ${pinentry_mac}/${pinentry_mac.binaryPath}
    '';

  home.stateVersion = "24.05";
}
