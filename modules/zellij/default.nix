{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.zellij;
in {
  options.modules.zellij = {enable = mkEnableOption "zellij";};

  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        default_layout = "compact";
      };
    };
  };
}
