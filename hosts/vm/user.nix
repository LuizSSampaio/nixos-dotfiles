{ config, lib, inputs, ... }:

{
  imports = [ ../../modules/default.nix ];

  config.modules = {
    hyprland.enable = true;
    ghostty.enable = true;
    git.enable = true;
    dunst.enable = true;
    walker.enable = true;
    waybar.enable = true;
    zsh.enable = true;
  };
}
