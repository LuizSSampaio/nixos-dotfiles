{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.ashell;
in {
  options.modules.ashell = {
    enable = mkEnableOption "ashell";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ashell
    ];
  };
}
