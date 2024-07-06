{ pkgs, ... }:
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neofetch
    neovim

    # system call monitoring
    tcpdump # network sniffer
    lsof # list open files
  ];

  # replace default editor with neovim
  environment.variables.EDITOR = "nvim";
}
