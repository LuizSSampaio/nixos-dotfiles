{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.antigravity-cli;
in
{
  options.modules.antigravity-cli = {
    enable = mkEnableOption "antigravity-cli AI coding assistant";
  };

  config = mkIf cfg.enable {
    programs.antigravity-cli = {
      enable = true;
      enableMcpIntegration = true;
      settings = {
        colorScheme = "terminal";
        editorMode = "vim";
        enableTelemetry = false;
      };
    };
  };
}
