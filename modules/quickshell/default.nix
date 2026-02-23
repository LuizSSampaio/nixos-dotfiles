{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  inherit (config.lib.stylix) colors;
  cfg = config.modules.quickshell;

  colorsQml = pkgs.writeText "Colors.qml" ''
    pragma Singleton
    import QtQuick

    QtObject {
      readonly property color base00: "#${colors.base00}"
      readonly property color base01: "#${colors.base01}"
      readonly property color base02: "#${colors.base02}"
      readonly property color base03: "#${colors.base03}"
      readonly property color base04: "#${colors.base04}"
      readonly property color base05: "#${colors.base05}"
      readonly property color base06: "#${colors.base06}"
      readonly property color base07: "#${colors.base07}"
      readonly property color base08: "#${colors.base08}"
      readonly property color base09: "#${colors.base09}"
      readonly property color base0A: "#${colors.base0A}"
      readonly property color base0B: "#${colors.base0B}"
      readonly property color base0C: "#${colors.base0C}"
      readonly property color base0D: "#${colors.base0D}"
      readonly property color base0E: "#${colors.base0E}"
      readonly property color base0F: "#${colors.base0F}"
    }
  '';

  configs = pkgs.runCommand "quickshell-configs" {} ''
    mkdir -p $out
    cp ${./configs/shell.qml} $out/shell.qml
    cp ${./configs/qmldir} $out/qmldir
    cp ${colorsQml} $out/Colors.qml
  '';
in {
  options.modules.quickshell = {
    enable = mkEnableOption "quick shell";
  };

  config = mkIf cfg.enable {
    programs.quickshell = {
      enable = true;
      activeConfig = toString configs;
      systemd.enable = true;
    };
  };
}
