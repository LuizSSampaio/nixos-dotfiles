{ pkgs, lib, config, ... }:

let cfg = config.modules.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      input = {
        kb_layout = "us";
        kb_variant = "intl";
        kb_options = "compose:caps";

        repeat_rate = 40;
        repeat_delay = 600;

        numlock_by_default = true;

        follow_mouse = 1;

        touchpad = {
          natural_scroll = true;

          scroll_factor = 0.4;
        };
      };

      misc = {
        key_press_enables_dpms = true; # key press will trigger wake
        mouse_move_enables_dpms = true; # mouse move will trigger wake
      };
    };
  };
}
