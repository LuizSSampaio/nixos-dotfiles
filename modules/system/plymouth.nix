{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.system.plymouth;
in {
  options.modules.system.plymouth = {
    enable = mkEnableOption "Plymouth boot splash";
  };

  config = mkIf cfg.enable {
    boot = {
      plymouth.enable = true;

      consoleLogLevel = 0;
      initrd.verbose = false;

      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];
    };

    stylix.targets.plymouth = {
      enable = true;
      logo =
        pkgs.nixos-icons
        + "/share/icons/hicolor/256x256/apps/nix-snowflake.png";
      logoAnimated = true;
    };
  };
}
