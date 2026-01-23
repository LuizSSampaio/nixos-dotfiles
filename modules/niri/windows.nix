{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.niri;

  # Helper for corner radius
  mkCornerRadius = r: {
    top-left = r;
    top-right = r;
    bottom-left = r;
    bottom-right = r;
  };
in {
  config = mkIf cfg.enable {
    programs.niri.settings.window-rules = [
      # Default rule: apply corner radius to all windows
      {
        geometry-corner-radius = mkCornerRadius 4.0;
        clip-to-geometry = true;
      }

      # Floating windows - system dialogs and utilities
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

      # Floating windows - Steam
      {
        matches = [
          {app-id = "^steam$";}
          {app-id = "^Steam$";}
        ];
        excludes = [
          {title = "^Steam$";} # Main window should tile
        ];
        open-floating = true;
      }

      # File dialogs
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

      # Picture-in-Picture windows
      {
        matches = [
          {title = "^Picture-in-Picture$";}
          {title = "Picture in picture";}
        ];
        open-floating = true;
        open-focused = false;
      }

      # Terminal windows - default to narrower
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

      # Zen browser - respect window opacity if set
      {
        matches = [
          {app-id = "^zen.*$";}
        ];
        opacity = 0.99;
      }

      # IDE/Editor windows - default to wider
      {
        matches = [
          {app-id = "^dev\\.zed\\.Zed$";}
          {app-id = "^code$";}
          {app-id = "^Code$";}
          {app-id = "^emacs$";}
          {app-id = "^Emacs$";}
        ];
        default-column-width = {
          proportion = 2.0 / 3.0;
        };
      }
    ];
  };
}
