{
  lib,
  config,
  pkgs,
  osConfig ? null,
  ...
}:
with lib;
let
  cfg = config.modules.noctalia;
  batteryThresholdCfg =
    if osConfig != null then
      osConfig.modules.system.batteryThreshold or { enable = false; }
    else
      config.modules.system.batteryThreshold or { enable = false; };
  batteryThresholdPluginEnabled = batteryThresholdCfg.enable or false;
in
{
  options.modules.noctalia = {
    enable = mkEnableOption "noctalia shell";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.noctalia = {
        enable = true;

        settings = {
          shell = {
            polkit_agent = true;
            telemetry_enabled = false;
            screen_time_enabled = true;
            animation = {
              enabled = true;
              speed = 1.0;
            };
            shadow = {
              direction = "down";
              alpha = 0.55;
            };
          };

          theme = {
            mode = mkDefault "dark";
            source = "custom";
            custom_palette = "stylix";
          };

          dock.enabled = false;
          wallpaper.enabled = false;
          weather.enabled = false;

          bar.main = {
            position = "top";
            capsule = true;
            smart_auto_hide = true;
            auto_hide = false;
            reserve_space = false;
            background_opacity = 0.8;
            start = [
              "launcher"
              "clock"
              "sysmon"
              "media"
            ];
            center = [
              "workspaces"
            ];
            end = [
              "tray"
              "notifications"
              "privacy"
              "battery"
            ]
            ++ optional batteryThresholdPluginEnabled "battery-threshold"
            ++ [
              "network"
              "control-center"
            ];
          };

          widget = {
            clock = {
              format = "{:%H:%M %a, %b %d}";
            };

            "control-center" = {
              glyph = "snowflake";
            };

            tray = {
              drawer = true;
            };

            privacy = {
              hide_inactive = true;
            };

            network = {
              vpn_status = "replace";
              show_label = true;
            };
          }
          // optionalAttrs batteryThresholdPluginEnabled {
            battery-threshold = {
              type = "local/battery-threshold:widget";
              sysfsPath = batteryThresholdCfg.sysfsPath;
              conservationUnit = "battery-threshold-mode@conservation.service";
              normalUnit = "battery-threshold-mode@normal.service";
              pollIntervalMs = 10000;
            };
          };

          plugins = optionalAttrs batteryThresholdPluginEnabled {
            enabled = [ "local/battery-threshold" ];
          };
        };
      };

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

      xdg.dataFile."noctalia/plugins/battery-threshold/plugin.toml" =
        mkIf batteryThresholdPluginEnabled
          {
            source = ./plugins/battery-threshold/plugin.toml;
          };
      xdg.dataFile."noctalia/plugins/battery-threshold/widget.luau" =
        mkIf batteryThresholdPluginEnabled
          {
            source = ./plugins/battery-threshold/widget.luau;
          };
    })

    # Niri integration: spawn noctalia on startup and enable overview type-to-launch & close-on-launch
    (mkIf (cfg.enable && (config.modules.niri.enable or false)) {
      programs.noctalia.settings.shell = {
        niri_overview_type_to_launch_enabled = true;
        niri_overview_close_on_launch_enabled = true;
      };
      programs.niri.settings.spawn-at-startup = [
        { command = [ "noctalia" ]; }
      ];
    })

    # Hyprland integration: exec noctalia on startup
    (mkIf (cfg.enable && (config.modules.hyprland.enable or false)) {
      wayland.windowManager.hyprland.settings.exec-once = [
        "noctalia"
      ];
    })
  ];
}
