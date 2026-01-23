{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.wlsunset;
in {
  options.modules.wlsunset = {
    enable = mkEnableOption "wlsunset blue light filter";

    latitude = mkOption {
      type = types.float;
      description = "Your latitude coordinate";
      example = -20.4;
    };

    longitude = mkOption {
      type = types.float;
      description = "Your longitude coordinate";
      example = -43.5;
    };

    temperature = {
      day = mkOption {
        type = types.int;
        default = 6500;
        description = "Color temperature during the day (in Kelvin)";
      };

      night = mkOption {
        type = types.int;
        default = 3500;
        description = "Color temperature at night (in Kelvin)";
      };
    };
  };

  config = mkIf cfg.enable {
    services.wlsunset = {
      enable = true;
      latitude = toString cfg.latitude;
      longitude = toString cfg.longitude;
      temperature = {
        inherit (cfg.temperature) day night;
      };
      systemdTarget = "graphical-session.target";
    };
  };
}
