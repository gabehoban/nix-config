{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.syscfg.server;
  root_ca = ''
    -----BEGIN CERTIFICATE-----
    MIIBnzCCAUagAwIBAgIRAKRDNdjx2rswIwQgK6vp8QMwCgYIKoZIzj0EAwIwLjER
    MA8GA1UEChMITGFiNCBQS0kxGTAXBgNVBAMTEExhYjQgUEtJIFJvb3QgQ0EwHhcN
    MjQxMDEyMDEyNjU3WhcNMzQxMDEwMDEyNjU3WjAuMREwDwYDVQQKEwhMYWI0IFBL
    STEZMBcGA1UEAxMQTGFiNCBQS0kgUm9vdCBDQTBZMBMGByqGSM49AgEGCCqGSM49
    AwEHA0IABJ3WciyHAr19dMbqMAem19ehCz/SXcKSenrkPS1Pl7HN8LTmf7ApcDWn
    KRP7wX1W+oz6tYmb33vRH977e7lmStujRTBDMA4GA1UdDwEB/wQEAwIBBjASBgNV
    HRMBAf8ECDAGAQH/AgEBMB0GA1UdDgQWBBSy/bLaM9sWWy+jqk6bE3fjGJ58HzAK
    BggqhkjOPQQDAgNHADBEAiBodYr3j8Lr+YbRW3oI8biO2Imn5kN6nKvYadIWlGjv
    EwIgS504i6cMr6y+qp9iaPKTRKt2hQbQB1HwXNGJa2tQpmo=
    -----END CERTIFICATE-----
  '';
  intermediate_ca = ''
    -----BEGIN CERTIFICATE-----
    MIIBxzCCAW6gAwIBAgIQTGpSOngdYFkdWbHK23DA5TAKBggqhkjOPQQDAjAuMREw
    DwYDVQQKEwhMYWI0IFBLSTEZMBcGA1UEAxMQTGFiNCBQS0kgUm9vdCBDQTAeFw0y
    NDEwMTIwMTI2NThaFw0zNDEwMTAwMTI2NThaMDYxETAPBgNVBAoTCExhYjQgUEtJ
    MSEwHwYDVQQDExhMYWI0IFBLSSBJbnRlcm1lZGlhdGUgQ0EwWTATBgcqhkjOPQIB
    BggqhkjOPQMBBwNCAASZOuoe8oBtadBu7X0feBRISp1j9jhCSe/dOb8jWpEuZbv6
    wjaQhuaiWkCCF6xlJsjwVuGh6kqKEApKk8QEdNVao2YwZDAOBgNVHQ8BAf8EBAMC
    AQYwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUQz1EG28OzinlrGPsZwbf
    fA0eYJcwHwYDVR0jBBgwFoAUsv2y2jPbFlsvo6pOmxN34xiefB8wCgYIKoZIzj0E
    AwIDRwAwRAIgFkSFqOsVcQ5vnMJNColEBUTamkXfUEPXXlHm2N7bCE4CIDxUKz41
    7WpcylUWe/KLF81bnXzascDPH5uiyUa+2Idl
    -----END CERTIFICATE-----
  '';
  root_ca_file = pkgs.writeTextFile {
    name = "root.ca";
    text = root_ca;
  };
  intermediate_ca_file = pkgs.writeTextFile {
    name = "intermediate.ca";
    text = intermediate_ca;
  };
in
{
  options.syscfg.server.step-ca = lib.mkOption {
    description = "Enables Step CA PKI Server";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf cfg.step-ca {
    users.groups.keys = { };

    sops.secrets.step_password = {
      mode = "0440";
      sopsFile = ../../secrets/step-ca.yaml;
      group = config.users.groups.keys.name;
    };
    sops.secrets.step_intermediate_ca_key = {
      mode = "0440";
      sopsFile = ../../secrets/step-ca.yaml;
      group = config.users.groups.keys.name;
    };

    security.pki.certificates = [
      root_ca
      intermediate_ca
    ];

    services.step-ca = {
      enable = true;
      address = "127.0.0.1";
      port = 8444;
      intermediatePasswordFile = config.sops.secrets.step_password.path;
      # See
      # https://smallstep.com/docs/step-ca/configuration#basic-configuration-options
      settings = {
        dnsNames = [
          "localhost"
          "127.0.0.1"
          "*.lab4.cc"
        ];
        root = root_ca_file;
        crt = intermediate_ca_file;
        key = config.sops.secrets.step_intermediate_ca_key.path;
        db = {
          type = "badger";
          dataSource = "/var/lib/step-ca/db";
        };
        authority = {
          claims = {
            minTLSCertDuration = "5m";
            maxTLSCertDuration = "24h";
            defaultTLSCertDuration = "24h";
          };
          provisioners = [
            {
              type = "ACME";
              name = "acme";
              forceCN = true;
            }
          ];
        };
      };
    };

    systemd.services.step-ca.serviceConfig = {
      SupplementaryGroups = [ config.users.groups.keys.name ];
    };
  };
}
