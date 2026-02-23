{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.system.polkit-kde;
in {
  options.modules.system.polkit-kde = {
    enable = mkEnableOption "KDE polkit authentication agent";
  };

  config = mkIf cfg.enable {
    systemd.user.services.polkit-kde-agent = {
      description = "KDE Polkit Authentication Agent";
      wantedBy = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
      };
    };
  };
}
