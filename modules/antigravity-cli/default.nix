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
      # The CLI writes runtime state (permissions, trusted workspaces) to
      # settings.json, so merge declared values into a writable file instead
      # of a read-only symlink (which aborts home-manager activation).
      mutableSettings = true;
      settings = {
        colorScheme = "terminal";
        editorMode = "vim";
        enableTelemetry = false;
      };
    };
  };
}
