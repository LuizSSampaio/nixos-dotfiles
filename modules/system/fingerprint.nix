{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.modules.system.fingerprint;
in
{
  options.modules.system.fingerprint = {
    enable = lib.mkEnableOption "fingerprint reader support via fprintd TOD";

    driver = lib.mkOption {
      type = lib.types.package;
      default = pkgs.libfprint-2-tod1-elan;
      defaultText = lib.literalExpression "pkgs.libfprint-2-tod1-elan";
      description = "libfprint TOD driver package for the fingerprint reader.";
    };

    pamServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "login"
        "sudo"
        "systemd-user"
        "polkit-1"
      ];
      description = ''
        PAM services that should accept fingerprint auth.
        Configured as 'sufficient' — fingerprint is tried first, password is the fallback.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.fprintd = {
      enable = true;
      package = pkgs.fprintd-tod;
      tod = {
        enable = true;
        driver = cfg.driver;
      };
    };

    # fprintd ships the daemon; PAM integration is opt-in per service.
    security.pam.services = builtins.listToAttrs (
      map (svc: lib.nameValuePair svc { fprintAuth = true; }) cfg.pamServices
    );
  };
}
