_: {
  programs.zathura = {
    enable = true;

    options = {
      adjust-open = "best-fit";
      font = "Iosevka 14";
      pages-per-row = "1";
      scroll-full-overlap = "0.01";
      scroll-page-aware = "true";
      scroll-step = "100";
      selection-clipboard = "clipboard";
      selection-notification = true;
      zoom-min = "10";
    };
  };
}
