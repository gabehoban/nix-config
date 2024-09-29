{
  lib,
  user,
  ...
}:
let
  sshKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqFRwe/auSdigp5l+XmgIABl8rIIFuwBh9I2WNRpIfYKYJRyKkLbYZO3Z56lCxqjJkTUIIdw+hsUvR3A71HVRnRlx05pMQ9IMn6XSrx+AQVXs/hBFNijQsmCVUMebop2kW1WZUfIgMg4+5L9VQPL+pX6ARKuXSf8Gv2Qn+rInpY1rYE9DesezjzA2Cljr3Pii1JlmqYDDLS2HnZ10FhJfutqWPUR9RnX4HcVXKcxE9rgHzjGSyNkaFVX2HG8SafePyABacoajNQVORn7PHD9RLUeQ+qM8IIvAVxig2JPt36AnWjakSumwgyf/NjrbjJTMlacN3zqresfcsa3+HdGki86QRbZ2bNRurrBbevxxzgQggjW0506drw49sN/y78BGuYjZJjQW3C7TPHaLpPBKMIEFz64vuwATZiLpSb/mfGqXvpXb9Yl91qYbOy6GdXOO54EMb4zM6pQn1n3h6uaneJ/ZjM2GarbcGE5d/Nxw3AsS7gVUBAXrkbHdmJnXzoZWKO1DGjx7fGnHHvyKZN997BEzGpTMIRbF7g2S0RLVVjVYmLJNpCPGxkWACeJN+CXYof/Yl1adeCmQVLagtO8HwsBQLRO2CJwveUwnNRK3WVOOM8DK+u5ROgg1XJO7ngXnP3HKql6ju0kYRpwlRj/dZNrsJh7tYDgXr/9B8I/9Q4w== cardno:17_077_465"
  ];
in
{
  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = lib.mkForce false;
      PubkeyAuthentication = lib.mkForce true;
      StreamLocalBindUnlink = true;
      UseDns = false;
      X11Forwarding = false;
      KexAlgorithms = [
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group16-sha512"
        "diffie-hellman-group18-sha512"
        "sntrup761x25519-sha512@openssh.com"
      ];
    };
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  users.users.${user}.openssh.authorizedKeys.keys = sshKeys;
  users.users.root.openssh.authorizedKeys.keys = sshKeys;
}
