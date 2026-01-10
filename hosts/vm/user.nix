{ config, lib, inputs, ... }:

{
  imports = [ ../../modules/default.nix ];

  config.modules = {
    hyprland.enable = true;
    ghostty.enable = true;
    ashell.enable = true;
    dunst.enable = true;
    walker.enable = true;
  };
}
