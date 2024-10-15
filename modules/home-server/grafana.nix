{
  config,
  lib,
  ...
}:
with config.networking;
let
  cfg = config.syscfg.server;
in
{
  options.syscfg.server.grafana = lib.mkOption {
    description = "Enables Grafana Server";
    type = lib.types.bool;
    default = false;
  };
  config = lib.mkIf cfg.grafana {
    services = {
      grafana = {
        enable = true;
        provision.enable = true;
        settings = {
          server = {
            http_addr = "127.0.0.1";
            domain = "grafana.${hostName}.lab4.cc";
          };
          auth = {
            disable_login_form = true;
            login_cookie_name = "_oauth2_proxy";
            oauth_auto_login = true;
            signout_redirect_url = "https://grafana.${hostName}.lab4.cc/oauth2/sign_out?rd=https%3A%2F%2Fgrafana.${hostName}.lab4.cc";
          };
          "auth.basic".enabled = false;
          "auth.proxy" = {
            enabled = true;
            auto_sign_up = true;
            enable_login_token = false;
            header_name = "X-Email";
            header_property = "email";
          };
          users = {
            allow_signup = false;
            auto_assign_org = true;
            auto_assign_org_role = "Viewer";
          };
        };
      };
      nginx.virtualHosts."grafana.${hostName}.lab4.cc" = {
        enableACME = true;
        forceSSL = true;
        acmeRoot = null;
        kTLS = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3000";
          proxyWebsockets = true;
        };
      };
      oauth2-proxy.nginx.virtualHosts."grafana.${hostName}.lab4.cc" = { };
    };
  };
}
