{ config, lib, inputs, ... }:

{
  imports = [ ../../modules/default.nix ];

  config.modules = {
    hyprland.enable = true;
    greetd.enable = true;
  };
}
