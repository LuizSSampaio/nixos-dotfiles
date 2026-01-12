{ pkgs, lib, config, ... }:

let cfg = config.modules.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      "$terminal" = lib.mkDefault "ghostty";
      "$mod" = lib.mkDefault "SUPER";

      bind = [
        "$mod, RETURN, exec, $terminal"
        "$mod, SPACE, exec, vicinae toggle"

        "$mod, W, killactive"

        # Apps
        "$mod SHIFT, F, exec, nautilus --new-window"
        "$mod SHIFT, B, exec, xdg-settings get default-web-browser"
        "$mod SHIFT, E, exec, emacs"
        "$mod SHIFT, slash, exec, 1password"

        # Control Tiling
        "$mod, P, togglesplit"
        "$mod, T, togglefloating"
        "$mod, F, fullscreen, 0"
        "$mod CTRL, F, fullscreenstate, 0 2"
        "$mod ALT, F, fullscreen, 1"

        # Move Focus
        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"

        # Swap window position
        "$mod SHIFT, H, swapwindow, l"
        "$mod SHIFT, J, swapwindow, d"
        "$mod SHIFT, K, swapwindow, u"
        "$mod SHIFT, L, swapwindow, r"

        # Resize window
        "$mod ALT, H, resizeactive, -100.0"
        "$mod ALT, J, resizeactive, 100.0"
        "$mod ALT, K, resizeactive, 0 -100.0"
        "$mod ALT, L, resizeactive, 0 100.0"

        # move and resize with mouse
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizeactive"

        # Clipboard
        "$mod, C, sendshortcut, CTRL, Insert"
        "$mod, V, sendshortcut, SHIFT, Insert"
        "$mod, X, sendshortcut, CTRL, X"

        # Screenshot
        ", Print, exec, watershot directory ~/Pictures/Screenshots --copy"

        # Brightness (with notification)
        ", XF86MonBrightnessUp, exec, brightnessctl -q s +10% && notify-send -h string:x-canonical-private-synchronous:brightness -h int:value:$(brightnessctl -m | cut -d, -f4 | tr -d '%') -t 1500 'Brightness'"
        ", XF86MonBrightnessDown, exec, brightnessctl -q s 10%- && notify-send -h string:x-canonical-private-synchronous:brightness -h int:value:$(brightnessctl -m | cut -d, -f4 | tr -d '%') -t 1500 'Brightness'"

        # Volume (with notification)
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ && notify-send -h string:x-canonical-private-synchronous:volume -h int:value:$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}') -t 1500 'Volume'"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && notify-send -h string:x-canonical-private-synchronous:volume -h int:value:$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}') -t 1500 'Volume'"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && notify-send -h string:x-canonical-private-synchronous:volume -t 1500 \"$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo 'Muted' || echo 'Unmuted')\""
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && notify-send -h string:x-canonical-private-synchronous:mic -t 1500 \"Mic $(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo 'Muted' || echo 'Unmuted')\""

        # Media player controls
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"

      ] ++ (builtins.concatLists (builtins.genList (i:
        let ws = i + 1;
        in [
          "$mod, code:1${toString i}, workspace, ${toString ws}"
          "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
          "$mod SHIFT ALT, code:1${toString i}, movetoworkspacesilent, ${
            toString ws
          }"
        ]) 9));
    };
  };
}
