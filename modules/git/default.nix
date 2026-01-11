{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.git;
in {
  options.modules.git = { enable = mkEnableOption "git"; };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      user = {
        name = "Luiz Henrique Silva Sampaio";
        email = "luizhsampaio07@gmail.com";
      };
    };
  };
}
