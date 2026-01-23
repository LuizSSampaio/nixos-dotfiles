{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.niri;
in {
  config = mkIf cfg.enable {
    programs.swaylock = {
      enable = true;
      settings = {
        ignore-empty-password = true;
        show-failed-attempts = true;

        indicator-radius = 100;
        indicator-thickness = 10;
      };
    };
  };
}
