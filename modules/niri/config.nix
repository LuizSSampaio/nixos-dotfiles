{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.niri;
  stylixImage = config.stylix.image or null;

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
      outputs = mkIf (cfg.monitors != []) (mkOutputs cfg.monitors);

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

      gestures.hot-corners.enable = false;

      layout = {
        gaps = 4;

        preset-column-widths = [
          {proportion = 1.0 / 3.0;}
          {proportion = 1.0 / 2.0;}
          {proportion = 2.0 / 3.0;}
        ];

        default-column-width = {
          proportion = 1.0 / 2.0;
        };

        border = {
          enable = true;
          width = 2;
        };

        focus-ring = {
          enable = false;
        };

        center-focused-column = "never";
      };

      environment = {
        DISPLAY = ":0"; # for xwayland-satellite

        # Desktop environment identification
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_DESKTOP = "niri";
      };

      spawn-at-startup =
        [
          {command = ["xwayland-satellite"];}
        ]
        ++ optional (stylixImage != null) {
          command = [
            "swaybg"
            "-i"
            "${stylixImage}"
            "-m"
            "fill"
          ];
        };

      prefer-no-csd = true;

      screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d %H-%M-%S.png";

      hotkey-overlay = {
        skip-at-startup = true;
      };
    };
  };
}
