{ pkgs, lib, config, ... }:

with lib;
let
  statusbar = "ashell";

  cfg = config.modules.hyprland;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      exec-once = [
        "${statusbar}"
      ];
    };
  };
}
