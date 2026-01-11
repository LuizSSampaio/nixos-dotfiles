{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.hyprland;
in {
  config = mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          no_fade_in = false;
        };
        auth = { fingerprint.enabled = true; };
        background = { monitor = ""; };

        input-field = {
          monitor = "";
          size = "600, 100";
          position = "0, 0";
          halign = "center";
          valign = "center";

          inner_color = "#908000";
          outer_color = "#d3c6aa";
          outline_thickness = 4;

          font_family = "JetBrainsMono Nerd Font";
          font_size = 32;
          font_color = "#d3c6aa";

          placeholder_color = "#d3c6aa";
          placeholder_text = "  Enter Password 󰈷 ";
          check_color = "rgba(131, 192, 146, 1.0)";
          fail_text = "Wrong";

          rounding = 0;
          shadow_passes = 0;
          fade_on_empty = false;
        };

        label = {
          monitor = "";
          text = "$FPRINTPROMPT";
          text_align = "center";
          color = "rgb(211, 198, 170)";
          font_size = 24;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, -100";
          halign = "center";
          valign = "center";
        };
      };
    };
  };
}
