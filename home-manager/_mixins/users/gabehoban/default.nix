{ config, lib, pkgs, ... }:
let
  inherit (pkgs.stdenv) isLinux;
in
{
  home = {
    file.".face".source = ./face.png;
    file."Builds/nixos-console.conf".text = ''
      #!/run/current-system/sw/bin/quickemu --vm
      guest_os="linux"
      disk_img="nixos-console/disk.qcow2"
      disk_size="96G"
      iso="nixos-console/nixos.iso"
    '';
    file."Builds/nixos-gnome.conf".text = ''
      #!/run/current-system/sw/bin/quickemu --vm
      guest_os="linux"
      disk_img="nixos-gnome/disk.qcow2"
      disk_size="96G"
      iso="nixos-gnome/nixos.iso"
      width="1920"
      height="1080"
    '';
    file."/DevOps/.keep".text = "";
  };
  programs = {
    fish.loginShellInit = ''
      ${pkgs.figurine}/bin/figurine -f "DOS Rebel.flf" $hostname
    '';
    git = {
      userEmail = "gabehoban@icloud.com";
      userName = "Gabriel Hoban";
    };
  };
}