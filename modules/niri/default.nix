{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.niri;
in {
  options.modules.niri = {
    enable = mkEnableOption "niri window manager";
  };

  config = mkIf cfg.enable {
    # Niri settings (programs.niri.enable is set by nixosModules.niri at system level)
    programs.niri.settings = {
      # Input configuration
      input = {
        keyboard.xkb = {
          layout = "us";
          variant = "intl";
        };

        touchpad = {
          tap = true;
          natural-scroll = true;
        };

        mouse = {
          accel-speed = 0.0;
        };
      };

      # Prefer no client-side decorations
      prefer-no-csd = true;

      # Screenshot path
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      # Keybindings
      binds = with config.lib.niri.actions; {
        # Window management
        "Mod+Q".action = close-window;
        "Mod+H".action = focus-column-left;
        "Mod+L".action = focus-column-right;
        "Mod+J".action = focus-window-down;
        "Mod+K".action = focus-window-up;

        # Arrow key alternatives
        "Mod+Left".action = focus-column-left;
        "Mod+Right".action = focus-column-right;
        "Mod+Down".action = focus-window-down;
        "Mod+Up".action = focus-window-up;

        # Moving windows
        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+L".action = move-column-right;
        "Mod+Shift+J".action = move-window-down;
        "Mod+Shift+K".action = move-window-up;

        "Mod+Shift+Left".action = move-column-left;
        "Mod+Shift+Right".action = move-column-right;
        "Mod+Shift+Down".action = move-window-down;
        "Mod+Shift+Up".action = move-window-up;

        # Workspaces
        # TODO:

        # Move window to workspace
        # TODO:

        # Workspace navigation
        "Mod+Page_Down".action = focus-workspace-down;
        "Mod+Page_Up".action = focus-workspace-up;
        "Mod+Shift+Page_Down".action = move-column-to-workspace-down;
        "Mod+Shift+Page_Up".action = move-column-to-workspace-up;

        # Column width adjustments
        "Mod+R".action = switch-preset-column-width;
        "Mod+F".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;
        "Mod+Minus".action = set-column-width "-10%";
        "Mod+Equal".action = set-column-width "+10%";

        # Window height adjustments
        "Mod+Shift+Minus".action = set-window-height "-10%";
        "Mod+Shift+Equal".action = set-window-height "+10%";

        # Consume/expel windows from column
        "Mod+BracketLeft".action = consume-window-into-column;
        "Mod+BracketRight".action = expel-window-from-column;

        # Center column
        "Mod+C".action = center-column;

        # Screenshot
        # "Print".action = screenshot;
        # "Ctrl+Print".action = screenshot-screen;
        # "Alt+Print".action = screenshot-window;

        # Session control
        "Mod+Ctrl+Shift+E".action = quit;

        # Media keys
        "XF86AudioPlay".action.spawn = [
          (lib.getExe pkgs.playerctl)
          "play-pause"
        ];
        "XF86AudioStop".action.spawn = [
          (lib.getExe pkgs.playerctl)
          "pause"
        ];
        "XF86AudioNext".action.spawn = [
          (lib.getExe pkgs.playerctl)
          "next"
        ];
        "XF86AudioPrev".action.spawn = [
          (lib.getExe pkgs.playerctl)
          "previous"
        ];
        "XF86AudioRaiseVolume".action.spawn = [
          "${pkgs.wireplumber}/bin/wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "5%+"
        ];
        "XF86AudioLowerVolume".action.spawn = [
          "${pkgs.wireplumber}/bin/wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "5%-"
        ];
      };

      # Layout configuration
      layout = {
        gaps = 8;
        center-focused-column = "never";

        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];

        default-column-width = { proportion = 0.5; };

        focus-ring = {
          enable = true;
          width = 2;
          active.color = "#7fc8ff";
          inactive.color = "#505050";
        };

        border = {
          enable = false;
        };
      };

      # Environment variables for Wayland compatibility
      environment = {
        NIXOS_OZONE_WL = "1";
        DISPLAY = ":0";
      };

      # Cursor configuration
      cursor = {
        size = 24;
      };

      # Hotkey overlay (shows keybindings on Mod press)
      hotkey-overlay.skip-at-startup = true;
    };

    # Install useful packages for niri
    home.packages = with pkgs; [
      # Wayland utilities
      wl-clipboard
      wl-clip-persist

      # Screenshot tool
      grim
      slurp

      # Screen locker
      swaylock

      # Notification daemon
      mako

      # XWayland
      xwayland
    ];

    # Enable mako for notifications
    services.mako = {
      enable = true;
      defaultTimeout = 5000;
    };
  };
}
