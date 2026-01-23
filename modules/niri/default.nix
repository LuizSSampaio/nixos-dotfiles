{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.niri;
in {
  imports = [
    ./config.nix
    ./bindings.nix
    ./windows.nix
    ./swayidle.nix
  ];

  options.modules.niri = {
    enable = mkEnableOption "niri window manager";

    monitors = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Monitor name (e.g., eDP-1, HDMI-A-1)";
            };
            width = mkOption {
              type = types.nullOr types.int;
              default = null;
              description = "Resolution width (null for auto)";
            };
            height = mkOption {
              type = types.nullOr types.int;
              default = null;
              description = "Resolution height (null for auto)";
            };
            refresh = mkOption {
              type = types.nullOr types.float;
              default = null;
              description = "Refresh rate in Hz (null for auto)";
            };
            x = mkOption {
              type = types.int;
              default = 0;
              description = "X position";
            };
            y = mkOption {
              type = types.int;
              default = 0;
              description = "Y position";
            };
            scale = mkOption {
              type = types.nullOr types.float;
              default = null;
              description = "Scale factor (null for auto)";
            };
            vrr = mkOption {
              type = types.bool;
              default = false;
              description = "Enable variable refresh rate";
            };
          };
        }
      );
      default = [];
      description = "List of monitor configurations for niri";
      example = [
        {
          name = "eDP-1";
          width = 1920;
          height = 1080;
          refresh = 60.0;
          x = 0;
          y = 0;
          scale = 1.0;
        }
      ];
    };
  };

  config = mkIf cfg.enable {
    programs.niri = {
      enable = true;
    };

    home.packages = with pkgs; [
      wl-clipboard
      brightnessctl
      playerctl
      libnotify
      xwayland-satellite
      jq
      swaybg
    ];

    services.playerctld.enable = true;
  };
}
