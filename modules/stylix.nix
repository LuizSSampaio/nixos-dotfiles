{ pkgs, ... }:

{
  stylix = {
    enable = true;

    base16Scheme =
      "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

    image = pkgs.fetchurl {
      url = "https://gruvbox-wallpapers.pages.dev/wallpapers/pixelart/dock.png";
      hash =
        "sha256-b7e95e0874aea54c0af2afdb1976f7389a5fd12b84905c57dbbb65168f06c6ff";
    };

    polarity = "dark";

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
    };
  };
}
