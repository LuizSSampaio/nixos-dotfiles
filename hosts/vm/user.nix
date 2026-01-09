{ config, lib, inputs, ... }:

{
  imports = [ ../../modules/default.nix ];

  config.modules = {
    hyprland.enable = true;
  };
}
