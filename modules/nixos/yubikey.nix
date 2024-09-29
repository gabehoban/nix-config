{ pkgs, ... }:
{
  hardware.gpgSmartcards.enable = true;

  environment.systemPackages = with pkgs; [
    age-plugin-yubikey
    # security integration
    libu2f-host
    gnupg
    # Yubico's official tools
    yubikey-manager # cli
    yubikey-manager-qt # gui
    yubikey-personalization # cli
    yubikey-personalization-gui # gui
    yubico-piv-tool # cli
  ];

  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    gpgconf --launch gpg-agent
    gpg-connect-agent updatestartuptty /bye > /dev/null
  '';

  programs = {
    ssh.startAgent = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    yubikey-touch-detector.enable = true;
  };

  services = {
    pcscd.enable = true;
    udev.packages = [ pkgs.yubikey-personalization ];
    yubikey-agent.enable = true;
  };
}
