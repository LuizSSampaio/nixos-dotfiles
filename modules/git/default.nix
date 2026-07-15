{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.git;
in {
  options.modules.git = {enable = mkEnableOption "git";};

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = "Luiz Henrique Silva Sampaio";
          email = "luiz@lsamp.dev";
        };
        credential.helper = "store";
      };
    };

    programs.gh = {
      enable = true;
      gitCredentialHelper = {enable = true;};
    };
  };
}
