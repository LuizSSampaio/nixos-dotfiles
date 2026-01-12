{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.hyprland;
in {
  config = mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;
      settings.splash = false;
    };
  };
}
