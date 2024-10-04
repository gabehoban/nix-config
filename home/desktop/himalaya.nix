{ inputs, ... }:
let
  # https://pimalaya.org/himalaya/cli/latest/configuration/icloud-mail.html
  iCloudMailSettings = {
    imap = {
      host = "imap.mail.me.com";
      port = 993;
    };
    smtp = {
      host = "smtp.mail.me.com";
      port = 587;
      tls.useStartTls = true;
    };
  };
in
{
  programs.fish.shellAliases = {
    H = "himalaya";
    Hr = "himalaya message read";
    Hd = "himalaya message delete";
    Hs = "himalaya account sync && himalaya";
  };

  programs.himalaya = {
    enable = true;
  };

  accounts.email.accounts = {
    "gabehoban@icloud.com" = iCloudMailSettings // {
      primary = true;
      realName = "Gabriel Hoban";
      address = "gabehoban@icloud.com";
      userName = "gabehoban@icloud.com";
      passwordCommand = "gpg --quiet --for-your-eyes-only --no-tty --decrypt ${inputs.self.outPath}/secrets/pgp-icloud-mail.asc";
      himalaya = {
        enable = true;
        settings.sync = {
          enable = true;
        };
      };
    };
  };
}
