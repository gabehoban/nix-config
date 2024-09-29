#!/usr/bin/env bash

sudo nix run \
    --extra-experimental-features "nix-command flakes" \
    'github:nix-community/disko#disko-install' \
    -- --flake .#"$1" --disk disk0 "$2"
