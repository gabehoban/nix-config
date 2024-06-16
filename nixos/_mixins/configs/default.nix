{ hostname, lib, pkgs,... }:
let
  build-all = import ./build-all.nix { inherit pkgs; };
  build-host = import ./build-host.nix { inherit pkgs; };
  build-iso = import ./build-iso.nix { inherit pkgs; };
  purge-gpu-caches = import ./purge-gpu-caches.nix { inherit pkgs; };
  switch-all = import ./switch-all.nix { inherit pkgs; };
  boot-host = import ./boot-host.nix { inherit pkgs; };
  switch-host = import ./switch-host.nix { inherit pkgs; };
  unroll-url = import ./unroll-url.nix { inherit pkgs; };
in
{
  environment.systemPackages = [
    build-all
    build-host
    build-iso
    purge-gpu-caches
    switch-all
    boot-host
    switch-host
    unroll-url
  ];
}
