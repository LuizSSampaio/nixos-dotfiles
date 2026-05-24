{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.modules.kitty;
in
{
  options.modules.kitty = {
    enable = mkEnableOption "kitty terminal emulator";
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;

      shellIntegration.enableZshIntegration = true;

      settings = {
        window_padding_width = "10 14";
        hide_window_decorations = "yes";
        confirm_os_window_close = 0;

        cursor_shape = "block";
        cursor_blink_interval = 0;
        cursor_trail = 1;
        cursor_trail_decay = "0.1 0.4";

        wheel_scroll_multiplier = 0.95;
        touch_scroll_multiplier = 0.95;
      };
    };
  };
}
