{ config, lib, inputs, ... }:

{
  imports = [ ../../modules/system/default.nix ];

  config.modules.system = {
    fonts.enable = true;
    greetd.enable = true;
  };
}
