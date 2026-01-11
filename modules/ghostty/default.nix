{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.ghostty;
in {
  options.modules.ghostty = {
    enable = mkEnableOption "ghostty terminal emulator";
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      package = pkgs.ghostty.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          mkdir -p $out/share/ghostty/themes
          cp -r ${
            pkgs.fetchFromGitHub {
              owner = "mbadolato";
              repo = "iTerm2-Color-Schemes";
              rev = "master";
              hash = "sha256-GZ6F+T1pTt5LLheu4/3pf0eBpwkd1wu3+l6ReFNUhac="
            }
          }/schemes/*.itermcolors $out/share/ghostty/themes/
        '';
      });
      enableZshIntegration = true;

      settings = {
        window-padding-x = 14;
        window-padding-y = 10;
        window-decoration = "none";
        background-opacity = 0.95;
        confirm-close-surface = false;
        resize-overlay = "never";
        gtk-toolbar-style = "flat";

        cursor-style = "block";
        cursor-style-blink = false;

        mouse-scroll-multiplier = 0.95;
      };
    };
  };
}
