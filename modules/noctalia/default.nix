{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.noctalia;
in
{
  options.modules.noctalia = {
    enable = mkEnableOption "noctalia shell";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.noctalia-shell = {
        enable = true;

        plugins = {
          version = 2;
          sources = [
            {
              name = "Noctalia Plugins";
              url = "https://github.com/noctalia-dev/noctalia-plugins";
              enabled = true;
            }
          ];
          states.polkit-agent = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
        };

        settings = {
          bar = {
            position = "top";
            barType = "floating";
            showCapsule = true;
            outerCorners = false;
            widgets = {
              left = [
                { id = "Launcher"; }
                {
                  id = "Clock";
                  formatHorizontal = "HH:mm ddd, MMM d";
                }
                { id = "SystemMonitor"; }
                { id = "MediaMini"; }
              ];
              center = [
                { id = "Workspace"; }
              ];
              right = [
                { id = "Tray"; }
                { id = "NotificationHistory"; }
                { id = "Brightness"; }
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

          location = {
            monthBeforeDay = false;
            weatherEnabled = false;
          };

          dock.enabled = false;

          colorSchemes = {
            darkMode = true;
            useWallpaperColors = false;
            predefinedScheme = "Noctalia (default)";
          };
        };
      };

      xdg.configFile."noctalia/plugins.json".force = true;
    })

    # Niri integration: spawn noctalia-shell on startup
    (mkIf (cfg.enable && (config.modules.niri.enable or false)) {
      programs.niri.settings.spawn-at-startup = [
        { command = [ "noctalia-shell" ]; }
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
