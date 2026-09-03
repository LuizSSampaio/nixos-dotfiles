{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.noctalia;
  batteryThresholdCfg = config.modules.system.batteryThreshold or { enable = false; };
  batteryThresholdPluginEnabled = batteryThresholdCfg.enable or false;
  batteryThresholdWidget = {
    id = "plugin:battery-threshold";
  };
  privacyIndicatorWidget = {
    id = "plugin:privacy-indicator";
  };
  tailscaleWidget = {
    id = "plugin:tailscale";
  };
  screenToolkitWidget = {
    id = "plugin:screen-toolkit";
  };
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
          states = {
            polkit-agent = {
              enabled = true;
              sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
            };
            privacy-indicator = {
              enabled = true;
              sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
            };
            tailscale = {
              enabled = true;
              sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
            };
            screen-toolkit = {
              enabled = true;
              sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
            };
          }
          // optionalAttrs batteryThresholdPluginEnabled {
            battery-threshold = {
              enabled = true;
              sourceUrl = "local://nixos-dotfiles/noctalia/battery-threshold";
            };
          };
        };

        pluginSettings = optionalAttrs batteryThresholdPluginEnabled {
          battery-threshold = {
            sysfsPath = batteryThresholdCfg.sysfsPath;
            conservationUnit = "battery-threshold-mode@conservation.service";
            normalUnit = "battery-threshold-mode@normal.service";
            pollIntervalMs = 10000;
          };
          privacy-indicator = {
            hideInactiveStates = true;
          };
          tailscale = {
            compactMode = true;
          };
        };

        settings = {
          bar = {
            position = "top";
            barType = "simple";
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
                privacyIndicatorWidget
                {
                  id = "Battery";
                  displayMode = "onhover";
                }
              ]
              ++ optional batteryThresholdPluginEnabled batteryThresholdWidget
              ++ [
                tailscaleWidget
                screenToolkitWidget
                {
                  id = "ControlCenter";
                  useDistroLogo = true;
                }
              ];
            };
          };

          general = {
            animationSpeed = 1;
            autoStartAuth = true;
            allowPasswordWithFprintd = true;
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

          wallpaper.enabled = false;

          controlCenter = {
            cards = [
              { id = "profile-card"; enabled = true; }
              { id = "shortcuts-card"; enabled = true; }
              { id = "audio-card"; enabled = true; }
              { id = "brightness-card"; enabled = true; }
              { id = "weather-card"; enabled = true; }
              { id = "media-sysmon-card"; enabled = true; }
            ];
          };
        };
      };

      xdg.configFile."noctalia/plugins.json".force = true;
      home.packages = with pkgs; [
        curl
        grim
        jq
        slurp
        tesseract
        imagemagick
        zbar
        translate-shell
        wl-screenrec
        gifski
      ];
      xdg.configFile."noctalia/plugins/battery-threshold/manifest.json" =
        mkIf batteryThresholdPluginEnabled
          {
            source = ./plugins/battery-threshold/manifest.json;
          };
      xdg.configFile."noctalia/plugins/battery-threshold/BatteryThresholdWidget.qml" =
        mkIf batteryThresholdPluginEnabled
          {
            source = ./plugins/battery-threshold/BatteryThresholdWidget.qml;
          };
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
