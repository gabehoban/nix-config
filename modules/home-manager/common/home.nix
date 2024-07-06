{ pkgs, ... }:
{
  imports = [ ./starship ];

  home.packages = with pkgs; [ nil ];

  home.sessionVariables = {
    EDITOR = "nvim";
    DIRENV_LOG_FORMAT = "";
  };

  home.sessionPath = [ "$HOME/.local/bin" ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "yarn"
      ];
      extraConfig = ''
        zstyle ':bracketed-paste-magic' active-widgets '.self-*'

        export GPG_TTY="$(tty)"
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
        gpgconf --launch gpg-agent
      '';
    };
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      auto_sync = true;
      dialect = "us";
      show_preview = true;
      style = "compact";
      sync_frequency = "1h";
      sync_address = "https://atuin.labrats.cc";
      update_check = false;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  programs.git = {
    enable = true;
    userName = "Gabriel Hoban";
    userEmail = "gabehoban@icloud.com";
    signing = {
      key = "0xAFD8F294983C4F95";
      signByDefault = true;
    };
    aliases = {
      root = "rev-parse --show-toplevel";
    };
    extraConfig = {
      init.defaultBranch = "main";
      merge.ff = true;
      pull.ff = "only";
      feature.manyFiles = true;
      advice.detatchedHead = false;
      url."git@github.com:".pushInsteadOf = "https://github.com/";
      url."git@gitlab.com:".pushInsteadOf = "https://gitlab.com/";
    };
    ignores = [ "/.direnv/" ];
  };

  programs.gpg = {
    enable = true;
    mutableTrust = false;
    mutableKeys = false;
    publicKeys = [
      {
        source = ../../../keys/gpg.asc;
        trust = "ultimate";
      }
    ];
    scdaemonSettings.disable-ccid = true;
    settings = {
      no-greeting = true;
      no-emit-version = true;
      no-comments = false;
      export-options = "export-minimal";
      keyid-format = "0xlong";
      with-fingerprint = true;
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity show-keyserver-urls";
      personal-cipher-preferences = "AES256";
      personal-digest-preferences = "SHA512";
      default-preference-list = "SHA512 SHA384 SHA256 RIPEMD160 AES256 TWOFISH BLOWFISH ZLIB BZIP2 ZIP Uncompressed";
      cipher-algo = "AES256";
      digest-algo = "SHA512";
      cert-digest-algo = "SHA512";
      compress-algo = "ZLIB";
      disable-cipher-algo = "3DES";
      weak-digest = "SHA1";
      s2k-cipher-algo = "AES256";
      s2k-digest-algo = "SHA512";
      s2k-mode = "3";
      s2k-count = "65011712";
    };
  };

  programs.lf = {
    enable = true;
    keybindings."<delete>" = "delete";
  };

  programs.htop.enable = true;
  programs.htop.settings = {
    show_program_path = 0;
    hide_userland_threads = 1;
  };

  programs.home-manager.enable = true;
}
