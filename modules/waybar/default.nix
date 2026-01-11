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

          # Workspaces - show 9 persistent workspaces
          "hyprland/workspaces" = {
            format = "{name}";
            on-click = "activate";
            all-outputs = false;
            sort-by = "id";
            persistent-workspaces = {
              "*" = 9; # 9 workspaces on every monitor
            };
          };

          # Clock - 24h format with day of week
          clock = {
            format = "{:%a %H:%M}";
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
          };

          # System tray
          tray = {
            icon-size = 16;
            spacing = 10;
          };

          # Bluetooth
          bluetooth = {
            format = " {status}";
            format-connected = " {device_alias}";
            format-connected-battery =
              " {device_alias} {device_battery_percentage}%";
            format-disabled = "";
            format-off = "";
            tooltip-format = ''
              {controller_alias}	{controller_address}

              {num_connections} connected'';
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

          # Network (WiFi)
          network = {
            format-wifi = " {essid}";
            format-ethernet = " {ipaddr}";
            format-linked = " {ifname}";
            format-disconnected = " Disconnected";
            tooltip-format = ''
              {ifname}: {ipaddr}/{cidr}
              {essid} ({signalStrength}%)'';
            on-click = "nm-connection-editor";
          };

          # Audio (PulseAudio/PipeWire)
          pulseaudio = {
            format = "{icon} {volume}%";
            format-bluetooth = " {volume}%";
            format-bluetooth-muted = " Muted";
            format-muted = " Muted";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [ "" "" "" ];
            };
            on-click = "pavucontrol";
            scroll-step = 5;
          };

          # Battery
          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = " {capacity}%";
            format-plugged = " {capacity}%";
            format-icons = [ "" "" "" "" "" ];
            tooltip-format = ''
              {timeTo}
              {power}W'';
          };
        };
      };

      # Gruvbox style
      style = ''
        /* Gruvbox color palette */
        @define-color bg #282828;
        @define-color bg-alt #3c3836;
        @define-color fg #ebdbb2;
        @define-color gray #928374;
        @define-color red #fb4934;
        @define-color green #b8bb26;
        @define-color yellow #fabd2f;
        @define-color blue #83a598;
        @define-color purple #d3869b;
        @define-color aqua #8ec07c;
        @define-color orange #fe8019;

        * {
          font-family: "JetBrainsMono Nerd Font", "Noto Sans", sans-serif;
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background-color: @bg;
          color: @fg;
          border-bottom: 2px solid @bg-alt;
        }

        #workspaces {
          margin: 0 4px;
        }

        #workspaces button {
          padding: 0 8px;
          margin: 4px 2px;
          border-radius: 4px;
          background-color: transparent;
          color: @gray;
          border: none;
          transition: all 0.2s ease;
        }

        #workspaces button:hover {
          background-color: @bg-alt;
          color: @fg;
        }

        #workspaces button.active {
          background-color: @purple;
          color: @bg;
          font-weight: bold;
        }

        #workspaces button.urgent {
          background-color: @red;
          color: @bg;
        }

        #workspaces button.empty {
          color: @gray;
        }

        #workspaces button.visible {
          color: @fg;
        }

        #clock {
          color: @fg;
          font-weight: bold;
        }

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

        #bluetooth,
        #network,
        #pulseaudio,
        #battery {
          padding: 0 10px;
          margin: 4px 2px;
          border-radius: 4px;
          background-color: @bg-alt;
          color: @fg;
        }

        #bluetooth {
          color: @blue;
        }

        #network {
          color: @aqua;
        }

        #network.disconnected {
          color: @red;
        }

        #pulseaudio {
          color: @yellow;
        }

        #pulseaudio.muted {
          color: @gray;
        }

        #battery {
          color: @green;
        }

        #battery.charging,
        #battery.plugged {
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
