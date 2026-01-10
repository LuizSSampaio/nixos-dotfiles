{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.walker;
in {
  options.modules.walker = {
    enable = mkEnableOption "walker launcher";
  };

  config = mkIf cfg.enable {
    imports = [inputs.walker.homeManagerModules.default];

    programs.walker = {
      enable = true;
      runAsService = true;
    };
  };
}
