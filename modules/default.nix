{ inputs, pkgs, config, ... }:

{
  home.stateVersion = "25.11";
  imports = [
    ./packages.nix
    ./stylix.nix
    ./hyprland
    ./emacs
    ./ghostty
    ./git
    ./ashell
    ./walker
    ./dunst
    ./starship
    ./waybar
    ./wofi
    ./zsh
  ];
}
