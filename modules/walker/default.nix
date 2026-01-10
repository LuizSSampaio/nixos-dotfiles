{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.walker;
in {
  options.modules.walker = {
    enable = mkEnableOption "walker launcher";
  };

  imports = [inputs.walker.homeManagerModules.default];

  config = mkIf cfg.enable {
    programs.walker = {
      enable = true;
      runAsService = true;
    };
  };
}
