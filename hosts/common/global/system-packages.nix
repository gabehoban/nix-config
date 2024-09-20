{pkgs, ...}: {
  # Configure Systemwide Packages
  environment.systemPackages = with pkgs; 
  [
    vim
    dnsutils
    wget
    git
    git-crypt
    tmux
    tree
    neofetch
    zsh
    htop
    sops
    util-linux
    exfatprogs
    nmap
    age
    ssh-to-age
    p7zip
    usbutils
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  programs.zsh.enable = true;
}
