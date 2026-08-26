{ pkgs, ... }: {
  stylix = {
    enable = true;

    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

    image = pkgs.fetchurl {
      url = "https://gruvbox-wallpapers.pages.dev/wallpapers/anime/wall.jpg";
      sha256 = "1yyzpffr4a9iklswfvzz1k69bc0g3dbrz68qv4yfhcrrq3fl1phf";
    };

    polarity = "dark";

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus";
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
