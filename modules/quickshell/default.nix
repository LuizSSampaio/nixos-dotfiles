{
  lib,
  config,
  ...
}:
with lib; let
  inherit (config.lib.stylix) colors;
  cfg = config.modules.quickshell;
  configs = builtins.path {
    path = ./configs;
    name = "quickshell-configs";
  };
in {
  options.modules.quickshell = {enable = mkEnableOption "quick shell";};

  config = mkIf cfg.enable {
    programs.quickshell = {
      enable = true;
      activeConfig = configs;
      systemd.enable = true;
    };
  };
}
