{ config, inputs, ... }:
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
  home.shellAliases = {
    H = "himalaya";
    Hr = "himalaya message read";
    Hd = "himalaya message delete";
    Hs = "himalaya account sync";
  };

  programs.himalaya = {
    enable = true;
  };

  age.secrets.icloudMailPass.rekeyFile = "${inputs.self.outPath}/secrets/icloudMailPass.age";
  accounts.email.accounts = {
    "gabehoban@icloud.com" = iCloudMailSettings // {
      primary = true;
      realName = "Gabriel Hoban";
      address = "gabehoban@icloud.com";
      userName = "gabehoban@icloud.com";
      passwordCommand = "cat ${config.age.secrets.icloudMailPass.path} | echo -n";
      himalaya = {
        enable = true;
        settings.sync = {
          enable = true;
        };
      };
    };
  };
}
