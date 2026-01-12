{ config, lib, inputs, ... }:

{
  imports = [ ../../modules/default.nix ];

  config.modules = {
    hyprland = {
      enable = true;
      monitors = [ ", 1920x1080@60, 0x0, 1" ];
    };
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
