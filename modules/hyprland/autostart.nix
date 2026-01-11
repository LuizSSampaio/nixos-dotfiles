{ pkgs, lib, config, ... }:

with lib;
let
  notification = "dunst";

  cfg = config.modules.hyprland;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      exec-once = [ "${notification}" ];
    };
  };
}
