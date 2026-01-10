{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.hyprland;
in {
  options.modules.hyprland = {
    enable = mkEnableOption "hyprland window manager";
  };

  config = mkIf cfg.enable {
    config.desktopEnvironment.startCmd = "start-hyprland";
    home.packages = with pkgs; [
      wl-clipboard hyprland
    ];

    wayland.windowManager.hyprland.enable = true;
    wayland.windowManager.hyprland.systemd.variables = ["--all"];
    home.sessionVariables.NIXOS_OZONE_WL = "1";

    services.hyprpolkitagent.enable = true;
  };
}
