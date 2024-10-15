{ config, lib, ... }:
with config.networking;
let
  cfg = config.syscfg.server;
in
{
  options.syscfg.server.oauth2 = lib.mkOption {
    description = "Enables OAUTH2 Service";
    type = lib.types.bool;
    default = false;
  };
  config = lib.mkIf cfg.oauth2 {
    sops.secrets.oauth2-env = {
      owner = "oauth2-proxy";
      sopsFile = ../../secrets/oauth2.yaml;
    };

    services = {
      oauth2-proxy = {
        enable = true;
        provider = "github";
        nginx.domain = "auth.${hostName}.lab4.cc";
        cookie.domain = ".${hostName}.lab4.cc";
        email.domains = [ "icloud.com" ];
        keyFile = config.sops.secrets.oauth2-env.path;
        reverseProxy = true;
        passBasicAuth = true;
        setXauthrequest = true;
        extraConfig = {
          skip-provider-button = true;
          whitelist-domain = "*.${hostName}.lab4.cc";
          cookie-samesite = "lax";
        };
      };
      nginx.virtualHosts."auth.${hostName}.lab4.cc" = {
        enableACME = true;
        forceSSL = true;
        kTLS = true;
        acmeRoot = null;
      };
    };
  };
}
