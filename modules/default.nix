{ inputs, pkgs, config, ... }:

{
  home.stateVersion = "25.11";
  imports = [
    ./packages.nix
    ./hyprland
    ./ghostty
    ./ashell
    ./walker
    ./dunst
    ./waybar
    ./zsh
  ];
}
