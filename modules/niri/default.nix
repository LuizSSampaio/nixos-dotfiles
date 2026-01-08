{ pkgs, lib, config, inputs, ... }:

with lib;
let cfg = config.modules.niri;

in {
  options.modules.niri = { enable = mkEnableOption "niri"; };

  config = mkIf cfg.enable {
    # Enable niri through the niri-flake module
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };

    # Basic niri configuration
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
      };

      # Prefer dark theme
      prefer-no-csd = true;

      # Screenshot configuration
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      # Basic keybindings
      binds = with config.lib.niri.actions; {
        # Window management
        "Mod+W".action = close-window;
        "Mod+H".action = focus-column-left;
        "Mod+L".action = focus-column-right;
        "Mod+J".action = focus-window-down;
        "Mod+K".action = focus-window-up;

        # Moving windows
        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+L".action = move-column-right;
        "Mod+Shift+J".action = move-window-down;
        "Mod+Shift+K".action = move-window-up;

        # Workspaces
        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;
        "Mod+6".action = focus-workspace 6;
        "Mod+7".action = focus-workspace 7;
        "Mod+8".action = focus-workspace 8;
        "Mod+9".action = focus-workspace 9;

        # Move to workspace
        "Mod+Shift+1".action = move-column-to-workspace 1;
        "Mod+Shift+2".action = move-column-to-workspace 2;
        "Mod+Shift+3".action = move-column-to-workspace 3;
        "Mod+Shift+4".action = move-column-to-workspace 4;
        "Mod+Shift+5".action = move-column-to-workspace 5;
        "Mod+Shift+6".action = move-column-to-workspace 6;
        "Mod+Shift+7".action = move-column-to-workspace 7;
        "Mod+Shift+8".action = move-column-to-workspace 8;
        "Mod+Shift+9".action = move-column-to-workspace 9;

        # Terminal
        # "Mod+Return".action = spawn "alacritty";

        # Launcher (using fuzzel as suggested in niri-flake docs)
        # "Mod+D".action = spawn "fuzzel";

        # Screenshot
        "Print".action = screenshot;
        "Ctrl+Print".action = screenshot-screen;
        "Alt+Print".action = screenshot-window;

        # Session control
        "Mod+Shift+E".action = quit;
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
          enable = true;
          width = 1;
          active.color = "#7fc8ff";
          inactive.color = "#505050";
        };
      };

      # Environment variables
      environment = {
        NIXOS_OZONE_WL = "1";
      };

      # Optional: Configure spawn-at-startup
      # spawn-at-startup = [
      #   { command = ["waybar"]; }
      #   { command = ["mako"]; }
      # ];
    };

    # Install useful packages for niri
    home.packages = with pkgs; [
      # Notification daemon
      mako

      # Utilities
      wl-clipboard

      # Screen locker
      swaylock
    ];

    # Enable mako for notifications
    services.mako = {
      enable = true;
      defaultTimeout = 5000;
    };
  };
}
