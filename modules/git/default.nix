{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.git;
in {
  options.modules.git = { enable = mkEnableOption "git"; };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = "Luiz Henrique Silva Sampaio";
      userEmail = "luizhsampaio07@gmail.com";
      extraConfig = { credential.helper = "store"; };
    };

    programs.gh = {
      enable = true;
      gitCredentialHelper = { enable = true; };
    };
  };
}
