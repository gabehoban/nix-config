_: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/core
    ../../modules/network
    ../../modules/server

    # Server Services
    ../../modules/server/nginx.nix
    ../../modules/server/postgres.nix
    ../../modules/server/attic.nix
    ../../modules/server/headscale
  ];
}
