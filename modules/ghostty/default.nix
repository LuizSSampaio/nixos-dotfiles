{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.ghostty;
in {
  options.modules.ghostty = {
    enable = mkEnableOption "ghostty terminal emulator";
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      settings = {
        # Window settings
        window-padding-x = 14;
        window-padding-y = 10;
        window-decoration = "none";
        background-opacity = 0.95;
        confirm-close-surface = false;
        resize-overlay = "never";
        gtk-toolbar-style = "flat";

        # Cursor styling
        cursor-style = "block";
        cursor-style-blink = false;

        # font-family = cfg.primary_font;
        font-style = "regular";
        font-size = 10;

        # Slowdown mouse scrolling
        mouse-scroll-multiplier = 0.95;

        theme = "gruvbox";
      };
    };
  };
}
