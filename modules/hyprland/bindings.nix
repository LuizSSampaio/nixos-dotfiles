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

        # Move and resize with mouse
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizeactive"

        # Clipboard
        "$mod, C, sendshortcut, CTRL, Insert"
        "$mod, V, sendshortcut, SHIFT, Insert"
        "$mod, X, sendshortcut, CTRL, X"

        # Screenshot
        ", Print, exec, watershot directory ~/Pictures/Screenshots --copy"

        # TODO: Media Keys
        # TODO: Groups
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
