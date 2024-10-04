{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    bindings = {
      "ALT+k" = "add sub-scale +0.1";
      "ALT+j" = "add sub-scale -0.1";
      "ALT+=" = "add video-zoom +0.1";
      "ALT+-" = "add video-zoom -0.1";
    };
    config = {
      ytdl-format = "bestvideo+bestaudio";
    };
    scripts = with pkgs.mpvScripts; [
      uosc # UI
      acompressor # ffmpeg audio compress
    ];
  };
}
