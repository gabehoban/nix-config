{ pkgs }:

pkgs.writeScriptBin "boot-host" ''
#!${pkgs.stdenv.shell}

if [ -e $HOME/nix-config ]; then
  pushd $HOME/nix-config
  sudo nixos-rebuild boot --flake .#
  popd
else
  ${pkgs.coreutils-full}/bin/echo "ERROR! No nix-config found in $HOME/nix-config"
fi
''
