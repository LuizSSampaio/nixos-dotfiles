{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.noctalia;
in {
  options.modules.noctalia = {
    enable = mkEnableOption "noctalia shell";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.noctalia-shell = {
        enable = true;

        settings = {
          bar = {
            position = "top";
            barType = "floating";
            showCapsule = true;
            backgroundOpacity = 0.93;
            widgets = {
              left = [
                {id = "Launcher";}
                {
                  id = "Clock";
                  formatHorizontal = "HH:mm ddd, MMM d";
                }
                {id = "SystemMonitor";}
                {id = "MediaMini";}
              ];
              center = [
                {id = "Workspace";}
              ];
              right = [
                {id = "Tray";}
                {id = "NotificationHistory";}
                {id = "Brightness";}
                {
                  id = "Battery";
                  displayMode = "alwaysShow";
                }
                {
                  id = "Volume";
                  displayMode = "alwaysShow";
                }
                {
                  id = "Bluetooth";
                  displayMode = "alwaysShow";
                }
                {
                  id = "ControlCenter";
                  useDistroLogo = true;
                }
              ];
            };
          };

          general = {
            animationSpeed = 1;
            enableShadows = true;
            lockOnSuspend = true;
            telemetryEnabled = false;
          };

          colorSchemes = {
            darkMode = true;
            useWallpaperColors = true;
            predefinedScheme = "Noctalia (default)";
          };
        };
      };
    })

    # Niri integration: spawn noctalia-shell on startup
    (mkIf (cfg.enable && (config.modules.niri.enable or false)) {
      programs.niri.settings.spawn-at-startup = [
        {command = ["noctalia-shell"];}
      ];
    })

    # Hyprland integration: exec noctalia-shell on startup
    (mkIf (cfg.enable && (config.modules.hyprland.enable or false)) {
      wayland.windowManager.hyprland.settings.exec-once = [
        "noctalia-shell"
      ];
    })
  ];
}
