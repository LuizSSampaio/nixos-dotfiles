{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.niri;
in {
  config = mkIf cfg.enable {
    programs.niri.settings.binds = with config.lib.niri.actions; let
      sh = spawn "sh" "-c";
    in {
      # Application launchers
      "Mod+Return".action = spawn "ghostty";
      "Mod+Space".action = spawn "vicinae" "toggle";

      "Mod+Shift+B".action = spawn "zen-beta";
      "Mod+Shift+F".action = spawn "nautilus" "--new-window";
      "Mod+Shift+E".action = spawn-sh "$EDITOR";
      "Mod+Shift+Slash".action = spawn "1password";

      # Window management
      "Mod+W".action = close-window;
      "Mod+Ctrl+Alt+Shift+E".action = quit;
      "Mod+Slash".action = show-hotkey-overlay;
      "Mod+O".action = toggle-overview;

      # Focus navigation (vim-style)
      "Mod+H".action = focus-column-left;
      "Mod+L".action = focus-column-right;
      "Mod+J".action = focus-window-down;
      "Mod+K".action = focus-window-up;

      # Move windows (vim-style)
      "Mod+Shift+H".action = move-column-left;
      "Mod+Shift+L".action = move-column-right;
      "Mod+Shift+J".action = move-window-down;
      "Mod+Shift+K".action = move-window-up;

      # First/last column
      "Mod+Alt+H".action = focus-column-first;
      "Mod+Alt+L".action = focus-column-last;
      "Mod+Alt+Shift+H".action = move-column-to-first;
      "Mod+Alt+Shift+L".action = move-column-to-last;

      # Monitor focus
      "Mod+Ctrl+H".action = focus-monitor-left;
      "Mod+Ctrl+L".action = focus-monitor-right;

      # Move window to monitor
      "Mod+Ctrl+Shift+H".action = move-column-to-monitor-left;
      "Mod+Ctrl+Shift+L".action = move-column-to-monitor-right;

      # Workspace navigation
      "Mod+Alt+J".action = focus-workspace-down;
      "Mod+Alt+K".action = focus-workspace-up;

      # Move window to workspace
      "Mod+Alt+Shift+J".action = move-column-to-workspace-down;
      "Mod+Alt+Shift+K".action = move-column-to-workspace-up;

      # Move workspace to monitor
      "Mod+Alt+Ctrl+J".action = move-workspace-down;
      "Mod+Alt+Ctrl+K".action = move-workspace-up;

      # Workspace switching (1-9)
      "Mod+1".action = focus-workspace 1;
      "Mod+2".action = focus-workspace 2;
      "Mod+3".action = focus-workspace 3;
      "Mod+4".action = focus-workspace 4;
      "Mod+5".action = focus-workspace 5;
      "Mod+6".action = focus-workspace 6;
      "Mod+7".action = focus-workspace 7;
      "Mod+8".action = focus-workspace 8;
      "Mod+9".action = focus-workspace 9;

      # Move window to workspace
      "Mod+Shift+1".action.move-window-to-workspace = 1;
      "Mod+Shift+2".action.move-window-to-workspace = 2;
      "Mod+Shift+3".action.move-window-to-workspace = 3;
      "Mod+Shift+4".action.move-window-to-workspace = 4;
      "Mod+Shift+5".action.move-window-to-workspace = 5;
      "Mod+Shift+6".action.move-window-to-workspace = 6;
      "Mod+Shift+7".action.move-window-to-workspace = 7;
      "Mod+Shift+8".action.move-window-to-workspace = 8;
      "Mod+Shift+9".action.move-window-to-workspace = 9;

      # Column/window sizing
      "Mod+R".action = switch-preset-column-width;
      "Mod+Alt+R".action = switch-preset-window-height;
      "Mod+F".action = maximize-column;
      "Mod+Alt+F".action = fullscreen-window;

      # Fine-grained sizing
      "Mod+Minus".action = set-column-width "-10%";
      "Mod+Equal".action = set-column-width "+10%";
      "Mod+Shift+Minus".action = set-window-height "-10%";
      "Mod+Shift+Equal".action = set-window-height "+10%";

      # Column manipulation
      "Mod+Comma".action = consume-window-into-column;
      "Mod+Period".action = expel-window-from-column;

      # Floating windows
      "Mod+V".action = toggle-window-floating;
      "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;

      # Screenshots
      "Print".action.screenshot = {};
      "Ctrl+Print".action.screenshot-screen = {};
      "Alt+Print".action.screenshot-window = {};

      # Media controls
      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && notify-send -t 1000 'Volume' $(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)\"%\"}')";
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && notify-send -t 1000 'Volume' $(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)\"%\"}')";
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action = sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };
      "XF86AudioMicMute" = {
        allow-when-locked = true;
        action = sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      };

      # Brightness controls
      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action = sh "brightnessctl set 5%+ && notify-send -t 1000 'Brightness' $(brightnessctl -m | cut -d, -f4)";
      };
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action = sh "brightnessctl set 5%- && notify-send -t 1000 'Brightness' $(brightnessctl -m | cut -d, -f4)";
      };

      # Media player controls
      "XF86AudioPlay" = {
        allow-when-locked = true;
        action = sh "playerctl play-pause";
      };
      "XF86AudioPause" = {
        allow-when-locked = true;
        action = sh "playerctl play-pause";
      };
      "XF86AudioNext" = {
        allow-when-locked = true;
        action = sh "playerctl next";
      };
      "XF86AudioPrev" = {
        allow-when-locked = true;
        action = sh "playerctl previous";
      };
    };
  };
}
