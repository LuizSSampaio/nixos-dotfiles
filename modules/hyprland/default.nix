{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.hyprland;
in {
  imports = [
    ./bindings.nix
    ./env.nix
    ./input.nix
    ./looknfeel.nix
    ./windows.nix
    ./hypridle.nix
    ./hyprpaper.nix
  ];

  options.modules.hyprland = {
    enable = mkEnableOption "hyprland window manager";

    monitors = mkOption {
      type = types.listOf types.str;
      default = [", preferred, auto, 1"];
      description = ''
        List of monitor configurations for Hyprland.
        Format: "name, resolution@rate, position, scale"
        Default uses auto-detection for all monitors.
      '';
      example = [
        "eDP-1, 1920x1080@60, 0x0, 1"
        "HDMI-A-1, 2560x1440@144, 1920x0, 1"
      ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      hyprland
      brightnessctl
      playerctl
      libnotify
    ];

    services.playerctld.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.variables = ["--all"];

      settings = {
        monitor = cfg.monitors;
      };
    };

    services.hyprpolkitagent.enable = true;
  };
}
