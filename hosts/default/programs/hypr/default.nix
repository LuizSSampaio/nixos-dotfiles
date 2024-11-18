{ config, lib, pkgs, ...}:
let
  super = "SUPER";
in
{
  imports = [ 
    ./hyprland-environment.nix
  ];

  home.packages = with pkgs; [
    waybar
    hyprlock
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      monitor = [
        ",preferred,auto,auto"
	"eDP-1,preferred,auto,2"
	"HDMI-A-1,1920x1080@240,-1440x0,auto"
      ];

      input = {
        kb_layout = "us";
        kb_variant = "intl";

        follow_mouse = 1;
        sensitivity = 0;

        touchpad = {
          natural_scroll = true;
        };
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;

        border_size = 2;
        resize_on_border = true;

        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        layout = "dwindle";
      };

      decoration = {
        rounding = 10;

        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";

        blur = {
          enabled = true;
	  size = 3;
	  passes = 1;
        };
      };

      animations = {
        enabled = true;
	bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
	animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default, slidevert"
          "specialWorkspace, 1, 6, default, fade"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      gestures = {
        workspace_swipe = true;
      };

      binds = {
        allow_workspace_cycles = true;
      };

      misc = {
        disable_hyprland_logo = true;
	animate_manual_resizes = true;
	animate_mouse_windowdragging = true;
	new_window_takes_over_fullscreen = 1;
	initial_workspace_tracking = 0;
      };

      windowrulev2 = [
        "suppressevent maximize, class:.*"
      ];

      bind = [
        "${super}, T, exec, kitty"
        "${super}, Q, killactive"
        "${super}, M, exit"
        "${super}, E, exec, nautilus"
        "${super}, F, exec, zen"
        "${super}, V, togglefloating"
        "${super}, SPACE, exec, rofi -show run"
        "${super}, P, pseudo"
        "${super}, J, togglesplit"

        "${super}, left, movefocus, l"
        "${super}, right, movefocus, r"
        "${super}, up, movefocus, u"
        "${super}, down, movefocus, d"

	"${super}, 1, workspace, 1"
	"${super}, 2, workspace, 2"
	"${super}, 3, workspace, 3"
	"${super}, 4, workspace, 4"
	"${super}, 5, workspace, 5"
	"${super}, 6, workspace, 6"
	"${super}, 7, workspace, 7"
	"${super}, 8, workspace, 8"
	"${super}, 9, workspace, 9"
	"${super}, 0, workspace, 0"

	"${super}_SHIFT, 1, movetoworkspace, 1"
	"${super}_SHIFT, 2, movetoworkspace, 2"
	"${super}_SHIFT, 3, movetoworkspace, 3"
	"${super}_SHIFT, 4, movetoworkspace, 4"
	"${super}_SHIFT, 5, movetoworkspace, 5"
	"${super}_SHIFT, 6, movetoworkspace, 6"
	"${super}_SHIFT, 7, movetoworkspace, 7"
	"${super}_SHIFT, 8, movetoworkspace, 8"
	"${super}_SHIFT, 9, movetoworkspace, 9"
	"${super}_SHIFT, 0, movetoworkspace, 0"

	"${super}, S, togglespecialworkspace, magic"
	"${super}_SHIFT, S, movetoworkspace, special:magic"

	"${super}, mouse_down, workspace, e+1"
	"${super}, mouse_up, workspace, e-1"
      ];

      bindm = [
        "${super}, mouse:272, movewindow"
        "${super}, mouse:273, resizewindow"
      ];

      cursor = {
        no_hardware_cursors = true;
      };
    };
  };
}
