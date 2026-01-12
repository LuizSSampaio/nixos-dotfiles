{ pkgs, ... }:

{
  stylix = {
    enable = true;

    base16Scheme =
      "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

    image = pkgs.fetchurl {
      url = "https://gruvbox-wallpapers.pages.dev/wallpapers/pixelart/dock.png";
      hash = "sha256-t+leCHSupUwK8q/bGXb3OJpf0SuEkFxX27tlFo8Gxv8=";
    };

    polarity = "dark";

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    icons = {
      enable = true;
      package = pkgs.yaru-theme;
      dark = "Yaru-prussiangreen";
      light = "Yaru-prussiangreen";
    };

    fonts = {
      serif = {
        package = pkgs.roboto-serif;
        name = "Roboto Serif";
      };
      sansSerif = {
        package = pkgs.roboto;
        name = "Roboto";
      };
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetbrainsMono Nerd Font";
      };
      emoji = {
        package = pkgs.openmoji-color;
        name = "OpenMoji Color";
      };

      sizes = {
        applications = 10;
        terminal = 10;
        desktop = 10;
        popups = 10;
      };
    };
  };

  # X resources for XWayland apps (e.g., Emacs) to use correct cursor size
  xresources.properties = {
    "Xcursor.theme" = "Bibata-Modern-Classic";
    "Xcursor.size" = 24;
  };
}
