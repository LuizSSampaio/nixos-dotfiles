{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      "$terminal" = lib.mkDefault "ghostty";
      "$mod" = lib.mkDefault "SUPER";

      bind = [
        "$mod, RETURN, exec, $terminal"

        "$mod, W, Close Window, killactive"

        # Control Tiling
        "$mod, P, Toggle window split, togglesplit"
        "$mod, T, Toggle window floating/tiling, togglefloating"
        "$mod, F, Full screen, fullscreen, 0"
        "$mod CTRL, F, Tiled full screen, fullscreenstate, 0 2"
        "$mod ALT, F, Full width, fullscreen, 1"

        # Move Focus
        "$mod, H, Move window focus left, movefocus, l"
        "$mod, J, Move window focus down, movefocus, d"
        "$mod, K, Move window focus up, movefocus, u"
        "$mod, L, Move window focus right, movefocus, r"

        # Swap window position
        "$mod SHIFT, H, Swap window to the left, swapwindow, l"
        "$mod SHIFT, J, Swap window to the down, swapwindow, d"
        "$mod SHIFT, K, Swap window to the up, swapwindow, u"
        "$mod SHIFT, L, Swap window to the right, swapwindow, r"

        # Resize window
        "$mod ALT, H, Resize window to the left, resizeactive, -100.0"
        "$mod ALT, J, Resize window to the down, resizeactive, 100.0"
        "$mod ALT, K, Resize window to the up, resizeactive, 0 -100.0"
        "$mod ALT, L, Resize window to the right, resizeactive, 0 100.0"

        # Move and resize with mouse
        "$mod, mouse:272, Move window, movewindow"
        "$mod, mouse:273, Resize window, resizewindow"

        # Clipboard
        "$mod, C, Copy to clipboard, sendshortcut, CTRL, Insert"
        "$mod, V, Paste from clipboard, sendshortcut, SHIFT, Insert"
        "$mod, X, Cut to clipboard, sendshortcut, CTRL, X"

        # TODO: Media Keys
        # TODO: Groups
      ] ++ (
        builtins.concatLists (builtins.genList (i:
          let ws = i + 1;
          in [
            "$mod, code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            "$mod SHIFT ALT, code:1${toString i}, movetoworkspacesilent, ${toString ws}"
          ])
        9)
      );
    };
  };
}
