{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.waybar;
in {
  options.modules.waybar = { enable = mkEnableOption "waybar"; };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          spacing = 4;

          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "clock" ];
          modules-right =
            [ "tray" "bluetooth" "network" "pulseaudio" "battery" ];

          # Workspaces with icons
          "hyprland/workspaces" = {
            format = "{icon}";
            on-click = "activate";
            all-outputs = false;
            sort-by = "id";
            persistent-workspaces = { "*" = 5; };
            format-icons = {
              "1" = "";
              "2" = "";
              "3" = "󰙯";
              "4" = "4";
              "5" = "5";
              "urgent" = "";
              "default" = "";
            };
          };

          # Clock with calendar icon
          clock = {
            format = " {:%a %H:%M}";
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
          };

          # System tray
          tray = {
            icon-size = 16;
            spacing = 10;
          };

          # Bluetooth - icon only, details on hover
          bluetooth = {
            format = "";
            format-connected = " {num_connections}";
            format-disabled = "󰂲";
            format-off = "󰂲";
            tooltip-format = ''
              {controller_alias}	{controller_address}

              {status}'';
            tooltip-format-connected = ''
              {controller_alias}	{controller_address}

              {num_connections} connected

              {device_enumerate}'';
            tooltip-format-enumerate-connected =
              "{device_alias}	{device_address}";
            tooltip-format-enumerate-connected-battery =
              "{device_alias}	{device_address}	{device_battery_percentage}%";
            on-click = "blueman-manager";
          };

          # Network - icon with signal indicator
          network = {
            format-wifi = "󰤨";
            format-ethernet = "󰈀";
            format-linked = "󰈀";
            format-disconnected = "󰤭";
            tooltip-format-wifi = ''
              {essid} ({signalStrength}%)
              {ifname}: {ipaddr}/{cidr}'';
            tooltip-format-ethernet = "{ifname}: {ipaddr}/{cidr}";
            tooltip-format-disconnected = "Disconnected";
            on-click = "nm-connection-editor";
          };

          # Audio - icon with volume
          pulseaudio = {
            format = "{icon}";
            format-bluetooth = "󰂯";
            format-bluetooth-muted = "󰂲";
            format-muted = "󰝟";
            format-icons = {
              headphone = "󰋋";
              hands-free = "󰋎";
              headset = "󰋎";
              phone = "";
              portable = "";
              car = "";
              default = [ "󰕿" "󰖀" "󰕾" ];
            };
            tooltip-format = ''
              {desc}
              Volume: {volume}%'';
            on-click = "pavucontrol";
            scroll-step = 5;
          };

          # Battery - icon only, percentage on hover
          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon}";
            format-charging = "󰂄";
            format-plugged = "󰚥";
            format-full = "󰁹";
            format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
            tooltip-format = ''
              {capacity}%
              {timeTo}
              {power}W'';
          };
        };
      };

      # Gruvbox style with enhanced workspace highlighting
      style = ''
        /* Gruvbox color palette */
        @define-color bg #282828;
        @define-color bg-alt #3c3836;
        @define-color fg #ebdbb2;
        @define-color fg-alt #d5c4a1;
        @define-color gray #928374;
        @define-color red #fb4934;
        @define-color green #b8bb26;
        @define-color yellow #fabd2f;
        @define-color blue #83a598;
        @define-color purple #d3869b;
        @define-color aqua #8ec07c;
        @define-color orange #fe8019;
        @define-color white #fbf1c7;

        * {
          font-family: "JetBrainsMono Nerd Font", monospace;
          font-size: 14px;
          min-height: 0;
        }

        window#waybar {
          background-color: @bg;
          color: @fg;
          border-bottom: 2px solid @bg-alt;
        }

        /* Workspaces */
        #workspaces {
          margin: 0 4px;
        }

        #workspaces button {
          padding: 0 10px;
          margin: 4px 2px;
          border-radius: 4px;
          background-color: transparent;
          color: @gray;
          border: none;
          transition: all 0.2s ease;
          font-size: 16px;
        }

        #workspaces button:hover {
          background-color: @bg-alt;
          color: @white;
        }

        /* Active workspace - purple background */
        #workspaces button.active {
          background-color: @purple;
          color: @bg;
          font-weight: bold;
        }

        /* Workspace with windows but not active - highlighted with yellow border */
        #workspaces button.visible:not(.active) {
          background-color: @bg-alt;
          color: @white;
          border: 1px solid @yellow;
        }

        /* Urgent workspace */
        #workspaces button.urgent {
          background-color: @red;
          color: @bg;
        }

        /* Empty workspace - dimmed */
        #workspaces button.empty {
          color: @gray;
        }

        /* Persistent workspace that has windows (not empty, not active) */
        #workspaces button.persistent:not(.empty):not(.active) {
          background-color: @bg-alt;
          color: @white;
          border: 1px solid @aqua;
        }

        /* Clock */
        #clock {
          color: @fg;
          font-weight: bold;
          padding: 0 12px;
        }

        /* Tray */
        #tray {
          margin: 0 8px;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: @red;
        }

        /* Common module styling */
        #bluetooth,
        #network,
        #pulseaudio,
        #battery {
          padding: 0 12px;
          margin: 4px 2px;
          border-radius: 4px;
          background-color: @bg-alt;
          color: @fg;
          font-size: 16px;
        }

        /* Bluetooth */
        #bluetooth {
          color: @blue;
        }

        #bluetooth.connected {
          color: @aqua;
        }

        #bluetooth.disabled,
        #bluetooth.off {
          color: @gray;
        }

        /* Network */
        #network {
          color: @aqua;
        }

        #network.disconnected {
          color: @red;
        }

        #network.linked {
          color: @yellow;
        }

        /* Audio */
        #pulseaudio {
          color: @yellow;
        }

        #pulseaudio.muted {
          color: @gray;
        }

        #pulseaudio.bluetooth {
          color: @blue;
        }

        /* Battery */
        #battery {
          color: @green;
        }

        #battery.charging,
        #battery.plugged,
        #battery.full {
          color: @green;
        }

        #battery.warning:not(.charging) {
          color: @orange;
        }

        #battery.critical:not(.charging) {
          background-color: @red;
          color: @bg;
          animation: blink 0.5s linear infinite alternate;
        }

        @keyframes blink {
          to {
            background-color: @bg;
            color: @red;
          }
        }
      '';
    };
  };
}
