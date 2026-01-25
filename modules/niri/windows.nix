{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.niri;
  inherit (config.lib.stylix) colors;

  mkCornerRadius = r: {
    top-left = r;
    top-right = r;
    bottom-left = r;
    bottom-right = r;
  };
in {
  config = mkIf cfg.enable {
    programs.niri.settings = {
      window-rules = [
        {
          geometry-corner-radius = mkCornerRadius 4.0;
          clip-to-geometry = true;
        }

        {
          matches = [
            {app-id = "^1[Pp]assword$";}
          ];
          block-out-from = "screencast";
        }

        {
          matches = [
            {is-window-cast-target = true;}
          ];
          focus-ring = {
            enable = true;
            active.color = "#${colors.base08}";
            inactive.color = "#${colors.base08}80";
          };
          border = {
            active.color = "#${colors.base08}";
            inactive.color = "#${colors.base08}80";
          };
        }

        {
          matches = [
            {
              app-id = "^steam$";
              title = "^notificationtoasts_\\d+_desktop$";
            }
          ];
          default-floating-position = {
            x = 10;
            y = 10;
            relative-to = "bottom-right";
          };
          open-focused = false;
        }

        {
          matches = [
            {app-id = "^1[Pp]assword$";}
            {app-id = "^org\\.gnome\\.Calculator$";}
            {
              app-id = "^org\\.gnome\\.Nautilus$";
              title = "^Properties$";
            }
            {app-id = "^file-roller$";}
            {app-id = "^org\\.gnome\\.FileRoller$";}
            {app-id = "^pavucontrol$";}
            {app-id = "^nm-connection-editor$";}
            {app-id = "^blueman-manager$";}
          ];
          open-floating = true;
        }

        {
          matches = [
            {app-id = "^steam$";}
            {app-id = "^Steam$";}
          ];
          excludes = [
            {title = "^Steam$";}
          ];
          open-floating = true;
        }

        {
          matches = [
            {title = "^Open File$";}
            {title = "^Save As$";}
            {title = "^Save File$";}
            {title = "^Open Folder$";}
            {title = "^Select Folder$";}
            {title = "^Choose Files$";}
            {title = "^File Upload$";}
          ];
          open-floating = true;
        }

        {
          matches = [
            {title = "^Picture-in-Picture$";}
            {title = "Picture in picture";}
          ];
          open-floating = true;
          open-focused = false;
        }

        {
          matches = [
            {app-id = "^ghostty$";}
            {app-id = "^Alacritty$";}
            {app-id = "^kitty$";}
            {app-id = "^foot$";}
          ];
          default-column-width = {
            proportion = 1.0 / 2.0;
          };
        }

        {
          matches = [
            {app-id = "^zen.*$";}
          ];
          open-maximized = true;
          open-on-output = "eDP-2";

          opacity = 0.99;
        }
      ];

      layer-rules = [
        {
          matches = [
            {namespace = "^notifications$";}
          ];
          block-out-from = "screencast";
        }
      ];
    };
  };
}
