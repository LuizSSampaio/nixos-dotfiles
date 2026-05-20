{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.system.batteryThreshold;

  applyScript = pkgs.writeShellScript "battery-threshold-apply" ''
    set -eu

    mode="$1"
    target="${cfg.sysfsPath}"

    case "$mode" in
      conservation)
        value=1
        ;;
      normal)
        value=0
        ;;
      *)
        echo "battery-threshold: unsupported mode: $mode" >&2
        exit 1
        ;;
    esac

    if [ ! -e "$target" ]; then
      echo "battery-threshold: sysfs path not found: $target" >&2
      exit 1
    fi

    printf '%s\n' "$value" > "$target"
  '';

  allowedUnits = [
    "battery-threshold-mode@conservation.service"
    "battery-threshold-mode@normal.service"
  ];

  allowedUnitsExpr = lib.concatStringsSep " || " (
    map (unit: ''unit == "${unit}"'') allowedUnits
  );
in
{
  options.modules.system.batteryThreshold = {
    enable = lib.mkEnableOption "Lenovo battery conservation mode support";

    mode = lib.mkOption {
      type = lib.types.enum [
        "normal"
        "conservation"
      ];
      default = "conservation";
      description = "Battery charging mode applied by the system service.";
    };

    sysfsPath = lib.mkOption {
      type = lib.types.str;
      default = "/sys/devices/pci0000:00/0000:00:14.3/PNP0C09:00/VPC2004:00/conservation_mode";
      description = "Sysfs path used to control the battery conservation mode.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.battery-threshold-apply = {
      description = "Apply configured battery conservation mode";
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${applyScript} ${cfg.mode}";
      };
    };

    systemd.services."battery-threshold-mode@" = {
      description = "Set battery conservation mode to %i";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${applyScript} %i";
      };
    };

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id !== "org.freedesktop.systemd1.manage-units") {
          return;
        }

        if (subject.user !== "luiz") {
          return;
        }

        var unit = action.lookup("unit");
        var verb = action.lookup("verb");

        if (verb === "start" && (${allowedUnitsExpr})) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
