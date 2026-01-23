{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.hyprland;
in {
  config = mkIf cfg.enable {
    home.sessionVariables = {
      HYPRCURSOR_SIZE = 24;
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
    };

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
