{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.hyprlock;
in
{
  options.modules.hyprlock = {
    enable = mkEnableOption "hyprlock screen locker";
  };

  config = mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          no_fade_in = false;
        };
        auth = {
          fingerprint.enabled = true;
        };
        background = {
          monitor = "";
        };

        input-field = {
          monitor = "";
          size = "600, 100";
          position = "0, 0";
          halign = "center";
          valign = "center";

          outline_thickness = 4;

          placeholder_text = "  Enter Password 󰈷 ";
          fail_text = "Wrong";

          rounding = 0;
          shadow_passes = 0;
          fade_on_empty = false;
        };

        label = {
          monitor = "";
          text = "$FPRINTPROMPT";
          text_align = "center";
          position = "0, -100";
          halign = "center";
          valign = "center";
        };
      };
    };
  };
}
