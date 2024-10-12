{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
let
  cfg = config.syscfg.applications;

  gpgKey = pkgs.fetchurl {
    url = "https://keys.openpgp.org/vks/v1/by-fingerprint/3EADE0CB32D1BC80DF96F538AFD8F294983C4F95";
    sha256 = "1695vlfryi09wyhphsj8i3rdm3635kk7wvwwdgpafxy9xjllsrcs";
  };
in
{
  options.syscfg.applications.gnupg.enable = lib.mkOption {
    description = "Enables GNUPG configurations";
    type = lib.types.bool;
    default = config.syscfg.graphics.apps;
  };
  config = lib.mkIf cfg.gnupg.enable {
    home-manager.users.${vars.user} = {
      programs.gpg = {
        enable = true;
        publicKeys = [
          {
            source = "${gpgKey}";
            trust = 5;
          }
        ];
        settings = {
          # Default/trusted key ID to use (helpful with throw-keyids)
          default-key = "3EADE0CB32D1BC80DF96F538AFD8F294983C4F95";
          trusted-key = "3EADE0CB32D1BC80DF96F538AFD8F294983C4F95";

          # Use AES256, 192, or 128 as cipher
          personal-cipher-preferences = "AES256 AES192 AES";
          # Use SHA512, 384, or 256 as digest
          personal-digest-preferences = "SHA512 SHA384 SHA256";
          # Use ZLIB, BZIP2, ZIP, or no compression
          personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
          # Default preferences for new keys
          default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
          # SHA512 as digest to sign keys
          cert-digest-algo = "SHA512";
          # SHA512 as digest for symmetric ops
          s2k-digest-algo = "SHA512";
          # AES256 as cipher for symmetric ops
          s2k-cipher-algo = "AES256";
          # UTF-8 support for compatibility
          charset = "utf-8";
          # Show Unix timestamps
          fixed-list-mode = "";
          # No comments in signature
          no-comments = "";
          # No version in signature
          no-emit-version = "";
          # Disable banner
          no-greeting = "";
          # Long hexidecimal key format
          keyid-format = "0xlong";
          # Display UID validity
          list-options = "show-uid-validity";
          verify-options = "show-uid-validity";
          # Display all keys and their fingerprints
          with-fingerprint = "";
          # Cross-certify subkeys are present and valid
          require-cross-certification = "";
          # Disable caching of passphrase for symmetrical ops
          no-symkey-cache = "";
          # Enable smartcard
          use-agent = "";
        };
      };
    };
  };
}
