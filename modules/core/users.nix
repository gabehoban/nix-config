{
  pkgs,
  user,
  ...
}:
{
  programs.zsh.enable = true;

  # TODO: Need to figure out why agenix does not work for storing hashed-passwords.
  users.users = {
    root.hashedPassword = "$7$CU..../....gVQlYp4OqDnCVfEOIPeSE.$XeegpKANj.ujK5DOheEhPl12vxGlzvp6W8ENHH7GDF3";
    ${user} = {
      isNormalUser = true;
      shell = pkgs.zsh;
      hashedPassword = "$7$CU..../....FZUZLOKbz7BuZigqQOVxq/$j2v.ltJRXmiTlwZYrfnS6mF.YwuEMu.wlStVgcqhll0";
      extraGroups = [
        "networkmanager"
        "wheel"
        "disk"
        "video"
        "input"
        "media"
      ];
    };
  };
}
