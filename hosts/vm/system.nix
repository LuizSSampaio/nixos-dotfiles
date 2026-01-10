{ config, lib, inputs, ... }:

{
  imports = [ ../../modules/system/default.nix ];

  config.modules.system = {
    greetd.enable = true;
  };
}
