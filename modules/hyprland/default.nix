{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.hyprland;
in {
  options.modules.hyprland = {
    enable = mkEnableOption "hyprland window manager";
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.enable = true;
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
