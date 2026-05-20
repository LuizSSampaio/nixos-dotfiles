{
  config,
  lib,
  ...
}:
with lib;
let
  hyprlandEnabled = config.modules.hyprland.enable or false;
  niriEnabled = config.modules.niri.enable or false;
  anyWaylandEnabled = hyprlandEnabled || niriEnabled;
  desktopName =
    if niriEnabled then
      "niri"
    else if hyprlandEnabled then
      "Hyprland"
    else
      null;
in
{
  config = mkIf anyWaylandEnabled {
    home.sessionVariables = {
      # Chromium/Electron Wayland support
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";

      # GTK Wayland support with fallbacks
      GDK_BACKEND = "wayland,x11,*";

      # GTK 4.20+ dead keys and compose support
      GTK_IM_MODULE = "simple";

      # Qt Wayland support with X11 fallback
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_STYLE_OVERRIDE = "kvantum";

      # SDL2 Wayland support
      SDL_VIDEODRIVER = "wayland";

      # Firefox Wayland support
      MOZ_ENABLE_WAYLAND = 1;

      # Session type indicator
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = desktopName;
      XDG_CURRENT_DESKTOP = desktopName;
    };
  };
}
