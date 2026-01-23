{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.waybar;

  hyprlandEnabled = config.modules.hyprland.enable or false;
  niriEnabled = config.modules.niri.enable or false;
  hasWM = hyprlandEnabled || niriEnabled;

  workspaceModule =
    if hyprlandEnabled
    then "hyprland/workspaces"
    else if niriEnabled
    then "niri/workspaces"
    else null;

  workspaceIcons = {
    "1" = "1";
    "2" = "2";
    "3" = "3";
    "4" = "4";
    "5" = "5";
    "6" = "6";
    "7" = "7";
    "8" = "8";
    "9" = "9";
    active = "󱓻";
    focused = "󱓻";
    default = "";
  };
in {
  options.modules.waybar = {
    enable = mkEnableOption "waybar";
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          spacing = 2;

          modules-left = optional hasWM workspaceModule;
          modules-center = ["clock"];
          modules-right = [
            "tray"
            "bluetooth"
            "network"
            "wireplumber"
            "battery"
          ];

          "hyprland/workspaces" = mkIf hyprlandEnabled {
            format = "{icon}";
            on-click = "activate";
            format-icons = workspaceIcons;
            persistent-workspaces = {
              "1" = [];
              "2" = [];
              "3" = [];
              "4" = [];
              "5" = [];
            };
          };

          "niri/workspaces" = mkIf niriEnabled {
            format = "{icon}";
            format-icons = workspaceIcons;
            all-outputs = false;
            disable-click = false;
          };

          clock = {
            format = "{:%a %H:%M}";
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
          };

          tray = {
            icon-size = 14;
            spacing = 13;
          };

          bluetooth = {
            format = "󰂯";
            format-disabled = "󰂲";
            format-connected = "";
            tooltip-format = "Devices connected: {num_connections}";
            on-click = "ghostty -e bluetui";
          };

          network = {
            format-icons = [
              "󰤯"
              "󰤟"
              "󰤢"
              "󰤥"
              "󰤨"
            ];
            format = "{icon}";
            format-wifi = "{icon}";
            format-ethernet = "󰀂";
            format-disconnected = "󰖪";
            tooltip-format-wifi = ''
              {essid} ({frequency} GHz)
              ⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}'';
            tooltip-format-ethernet = "⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
            tooltip-format-disconnected = "Disconnected";
            interval = 3;
            nospacing = 1;
            on-click = "ghostty -e impala";
          };

          wireplumber = {
            format = "{icon}";
            format-muted = "󰝟";
            format-icons = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
            scroll-step = 5;
            on-click = "ghostty -e wiremix";
            tooltip-format = "Playing at {volume}%";
            on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            max-volume = 150;
          };

          battery = {
            interval = 5;
            format = "{capacity}% {icon}";
            format-discharging = "{icon}";
            format-charging = "{icon}";
            format-plugged = "";
            format-icons = {
              charging = [
                "󰢜"
                "󰂆"
                "󰂇"
                "󰂈"
                "󰢝"
                "󰂉"
                "󰢞"
                "󰂊"
                "󰂋"
                "󰂅"
              ];
              default = [
                "󰁺"
                "󰁻"
                "󰁼"
                "󰁽"
                "󰁾"
                "󰁿"
                "󰂀"
                "󰂁"
                "󰂂"
                "󰁹"
              ];
            };
            format-full = "{icon}";
            tooltip-format-discharging = "{power:>1.0f}W↓ {capacity}%";
            tooltip-format-charging = "{power:>1.0f}W↑ {capacity}%";
            states = {
              warning = 20;
              critical = 10;
            };
          };
        };
      };

      style = ''
        * {
          font-family: JetBrains Mono Nerd Font;
          font-size: 12px;
        }

        .modules-left {
          margin-left: 8px;
        }

        .modules-right {
          margin-right: 8px;
        }

        #workspaces button {
          all: initial;
          padding: 0px 6px;
          margin: 0 1.5px;
          transition: all 0.2s ease;
        }

        #workspaces button.empty {
          opacity: 0.5;
        }

        #workspaces button.active,
        #workspaces button.focused {
        }

        #clock {
          font-weight: bold;
          padding: 4px 12px;
        }

        #tray {
          padding: 4px 8px;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: @red;
        }

        #bluetooth,
        #network,
        #wireplumber,
        #battery {
          padding: 4px 10px;
          margin: 0 2px;
        }
      '';
    };
  };
}
