{
  gnome = import ./gnome.nix;
  hm = import ./hm.nix;
  nix = import ./nix.nix;
  nixpkgs = import ./nixpkgs.nix;
  packages = import ./packages.nix;
  pc = import ./pc.nix;
  pipewire = import ./pipewire.nix;
  steam = import ./steam.nix;
  users = import ./users.nix;
  virt-manager = import ./virt-manager.nix;
  zram = import ./zram.nix;
}
