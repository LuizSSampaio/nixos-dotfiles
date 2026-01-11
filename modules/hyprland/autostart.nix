{ pkgs, lib, config, ... }:

with lib;
let
  statusbar = "ashell";
  notification = "dunst";

  cfg = config.modules.hyprland;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      exec-once = [ "${statusbar}" "${notification}" ];
    };
  };
}
