{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.niri;

  outputs-off = pkgs.writeShellScript "niri-outputs-off" ''
    for output in $(${pkgs.niri}/bin/niri msg --json outputs | ${pkgs.jq}/bin/jq -r 'keys[]'); do
      ${pkgs.niri}/bin/niri msg output "$output" off
    done
  '';

  outputs-on = pkgs.writeShellScript "niri-outputs-on" ''
    for output in $(${pkgs.niri}/bin/niri msg --json outputs | ${pkgs.jq}/bin/jq -r 'keys[]'); do
      ${pkgs.niri}/bin/niri msg output "$output" on
    done
  '';
in {
  config = mkIf cfg.enable {
    services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 300;
          command = "${pkgs.systemd}/bin/loginctl lock-session";
        }
        {
          timeout = 330;
          command = toString outputs-off;
          resumeCommand = "${toString outputs-on} && ${pkgs.brightnessctl}/bin/brightnessctl -r";
        }
      ];
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.systemd}/bin/loginctl lock-session";
        }
        {
          event = "lock";
          command = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
        }
      ];
    };
  };
}
