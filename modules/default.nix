{ inputs, pkgs, config, ... }:

{
  home.stateVersion = "25.11";
  imports = [
    ./packages.nix
    ./hyprland
    ./ghostty
    ./git
    ./ashell
    ./walker
    ./dunst
    ./starship
    ./waybar
    ./zsh
  ];
}
