{ config, lib, inputs, ... }:

{
  imports = [ ../../modules/default.nix ];

  config.modules = {
    hyprland.enable = true;
    ghostty.enable = true;
    git.enable = true;
    dunst.enable = true;
    starship.enable = true;
    waybar.enable = true;
    watershot.enable = true;
    zsh.enable = true;
    emacs.enable = true;
    vicinae.enable = true;
    zen-browser.enable = true;
  };
}
