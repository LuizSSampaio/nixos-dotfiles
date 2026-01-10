{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.hyprland;
in {
  config = mkIf cfg.enable {
    home.sessionVariables.NIXOS_OZONE_WL = "1";

    home.sessionVariables.XCURSOR_SIZE = 24;
    home.sessionVariables.HYPRCURSOR_SIZE = 24;

    home.sessionVariables.GDK_BACKEND = "wayland,x11,*";
    home.sessionVariables.QT_QPA_PLATFORM = "wayland;xcb";
    home.sessionVariables.QT_STYLE_OVERRIDE = "kvantum";
    home.sessionVariables.SDL_VIDEODRIVER = "wayland";
    home.sessionVariables.MOZ_ENABLE_WAYLAND = 1;
    home.sessionVariables.ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    home.sessionVariables.XDG_SESSION_TYPE = "wayland";

    home.sessionVariables.XDG_CURRENT_DESKTOP = "Hyprland";
    home.sessionVariables.XDG_SESSION_DESKTOP = "Hyprland";

    wayland.windowManager.hyprland.settings = {
      xwayland = {
        force_zero_scaling = true;
      };

      ecosystem = {
        no_update_news = true;
      };
    };
  };
}
