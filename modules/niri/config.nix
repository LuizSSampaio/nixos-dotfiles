{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.niri;

  # Build output configuration from monitors option
  mkOutputs = monitors:
    builtins.listToAttrs (
      map (m: {
        inherit (m) name;
        value = {
          mode =
            if m.width != null && m.height != null
            then {
              inherit (m) width height refresh;
            }
            else null;
          position = {
            inherit (m) x y;
          };
          inherit (m) scale;
          variable-refresh-rate = m.vrr;
        };
      })
      monitors
    );
in {
  config = mkIf cfg.enable {
    programs.niri.settings = {
      # Output/monitor configuration
      outputs = mkIf (cfg.monitors != []) (mkOutputs cfg.monitors);

      # Input configuration
      input = {
        keyboard = {
          xkb = {
            layout = "us";
            variant = "intl";
            options = "compose:caps";
          };
          repeat-rate = 40;
          repeat-delay = 600;
        };

        touchpad = {
          tap = true;
          dwt = true; # disable while typing
          natural-scroll = true;
          scroll-factor = 0.4;
          accel-speed = 0.2;
        };

        mouse = {
          accel-speed = 0.0;
        };

        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "0%";
        };
      };

      # Layout configuration
      layout = {
        gaps = 6;

        # Preset column widths to cycle through
        preset-column-widths = [
          {proportion = 1.0 / 3.0;}
          {proportion = 1.0 / 2.0;}
          {proportion = 2.0 / 3.0;}
        ];

        # Default column width
        default-column-width = {
          proportion = 1.0 / 2.0;
        };

        # Border around focused window
        border = {
          enable = true;
          width = 2;
        };

        # Disable focus ring (using border instead)
        focus-ring = {
          enable = false;
        };

        # Center focused column when it doesn't fit
        center-focused-column = "never";
      };

      # Cursor configuration
      cursor = {
        xcursor-theme = "Adwaita";
        xcursor-size = 24;
      };

      # Environment variables
      environment = {
        DISPLAY = ":0"; # for xwayland-satellite
      };

      # Spawn at startup
      spawn-at-startup = [
        {command = ["waybar"];}
        {command = ["xwayland-satellite"];}
      ];

      # Prefer server-side decorations
      prefer-no-csd = true;

      # Screenshot path
      screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d %H-%M-%S.png";

      # Hotkey overlay (shows keybindings on Super press)
      hotkey-overlay = {
        skip-at-startup = true;
      };
    };
  };
}
