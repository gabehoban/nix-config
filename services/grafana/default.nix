{ config, ... }:
with config.networking;
{
  security.acme.certs."grafana.${hostName}.lab4.cc" = { };

  services = {
    grafana = {
      enable = true;
      provision.enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          domain = "grafana.${hostName}.lab4.cc";
        };
        auth.anonymous.enabled = true;
        # auth = {
        #   disable_login_form = true;
        #   login_cookie_name = "_oauth2_proxy";
        #   oauth_auto_login = true;
        #   signout_redirect_url = "https://grafana.${hostName}.lab4.cc/oauth2/sign_out?rd=https%3A%2F%2Fgrafana.${hostName}.lab4.cc";
        # };
        # "auth.basic".enabled = false;
        # "auth.proxy" = {
        #   enabled = true;
        #   auto_sign_up = true;
        #   enable_login_token = false;
        #   header_name = "X-Email";
        #   header_property = "email";
        # };
        users = {
          allow_signup = false;
          auto_assign_org = true;
          auto_assign_org_role = "Viewer";
        };
      };
    };
    nginx.virtualHosts."grafana.${hostName}.lab4.cc" = {
      useACMEHost = "grafana.${hostName}.lab4.cc";
      forceSSL = true;
      kTLS = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
      };
    };
    # oauth2-proxy.nginx.virtualHosts."grafana.${hostName}.lab4.cc" = { };
  };
}
