{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.hypridle;

  # Script to turn off monitors based on the active window manager
  dpmsOffScript = pkgs.writeShellScript "dpms-off" ''
    case "$XDG_CURRENT_DESKTOP" in
      Hyprland)
        hyprctl dispatch dpms off
        ;;
      niri)
        niri msg action power-off-monitors
        ;;
      *)
        # Fallback: try hyprctl first, then niri
        hyprctl dispatch dpms off 2>/dev/null || niri msg action power-off-monitors 2>/dev/null
        ;;
    esac
  '';

  # Script to turn on monitors based on the active window manager
  dpmsOnScript = pkgs.writeShellScript "dpms-on" ''
    case "$XDG_CURRENT_DESKTOP" in
      Hyprland)
        hyprctl dispatch dpms on
        ;;
      niri)
        # niri automatically turns on monitors on activity, but we can ensure it
        niri msg action power-on-monitors 2>/dev/null || true
        ;;
      *)
        # Fallback: try hyprctl first, then niri
        hyprctl dispatch dpms on 2>/dev/null || niri msg action power-on-monitors 2>/dev/null || true
        ;;
    esac
    # Restore brightness after waking up
    ${pkgs.brightnessctl}/bin/brightnessctl -r 2>/dev/null || true
  '';
in {
  options.modules.hypridle = {
    enable = mkEnableOption "hypridle idle daemon";
  };

  config = mkIf cfg.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "${dpmsOnScript}";
        };
        listener = [
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 330;
            on-timeout = "${dpmsOffScript}";
            on-resume = "${dpmsOnScript}";
          }
        ];
      };
    };
  };
}
