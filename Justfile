default:
    @just --choose

deploy rhost:
    nixos-rebuild switch --target-host root@{{rhost}} --flake .#{{rhost}}
