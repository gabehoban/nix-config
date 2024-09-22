{ lib, ... }:
{
  security.tpm2 = {
    enable = true;

    # enable Trusted Platform 2 userspace resource manager daemon
    abrmd.enable = lib.mkDefault false;

    # The TCTI is the "Transmission Interface" that is used to communicate with a
    # TPM. this option sets TCTI environment variables to the specified values if enabled
    #  - TPM2TOOLS_TCTI
    #  - TPM2_PKCS11_TCTI
    tctiEnvironment.enable = lib.mkDefault true;

    # enable TPM2 PKCS#11 tool and shared library in system path
    pkcs11.enable = lib.mkDefault false;
  };
}
