{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.niri.dynamicRefreshRate;
  niriPackage = config.programs.niri.package or pkgs.niri;

  refreshScript = pkgs.writeShellScript "niri-dynamic-refresh-rate" ''
    set -u

    export PATH="${lib.makeBinPath [
      pkgs.coreutils
      pkgs.findutils
      pkgs.jq
      niriPackage
    ]}:$PATH"

    output=${lib.escapeShellArg cfg.output}
    ac_refresh=${toString cfg.acRefreshRate}
    battery_refresh=${toString cfg.batteryRefreshRate}
    poll_interval=${toString cfg.pollInterval}

    log() {
      printf '%s\n' "niri-dynamic-refresh-rate: $*" >&2
    }

    on_ac_power() {
      for supply in /sys/class/power_supply/*; do
        [ -r "$supply/type" ] || continue
        [ "$(cat "$supply/type")" = "Mains" ] || continue
        [ -r "$supply/online" ] || continue

        if [ "$(cat "$supply/online")" = "1" ]; then
          return 0
        fi
      done

      return 1
    }

    discover_niri_socket() {
      if [ -n "''${NIRI_SOCKET:-}" ] && [ -S "$NIRI_SOCKET" ]; then
        return 0
      fi

      runtime_dir="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
      socket="$(
        find "$runtime_dir" -maxdepth 1 -type s -name 'niri.*.sock' -printf '%T@ %p\n' 2>/dev/null \
          | sort -nr \
          | head -n 1 \
          | cut -d' ' -f2-
      )"

      if [ -n "$socket" ]; then
        export NIRI_SOCKET="$socket"
        return 0
      fi

      return 1
    }

    pick_mode() {
      target="$1"

      discover_niri_socket || return 1

      if ! outputs_json="$(niri msg --json outputs 2>/dev/null)"; then
        unset NIRI_SOCKET
        return 1
      fi

      printf '%s\n' "$outputs_json" | jq -r --arg output "$output" --argjson target "$target" '
        def output_entries:
          if type == "array" then
            .[]
          elif type == "object" then
            to_entries[] | (.value + { name: (.value.name // .key) })
          else
            empty
          end;

        def hz:
          if has("refresh_rate") then
            (.refresh_rate / 1000)
          elif has("refresh") then
            .refresh
          else
            null
          end;

        def distance($a; $b):
          ($a - $b) as $d | if $d < 0 then -$d else $d end;

        output_entries
        | select(.name == $output)
        | (.current_mode // ([.modes[]? | select(.is_preferred == true)][0]) // .modes[0]?) as $base
        | ($base.width // empty) as $width
        | ($base.height // empty) as $height
        | [
            .modes[]?
            | select(.width == $width and .height == $height)
            | hz as $hz
            | select($hz != null and distance($hz; $target) < 1.0)
            | "\(.width)x\(.height)@\($hz)"
          ][0] // empty
      '
    }

    apply_refresh() {
      target="$1"
      mode="$(pick_mode "$target")"

      if [ -z "$mode" ]; then
        log "no $output mode found near ''${target}Hz"
        return 1
      fi

      if ! niri msg output "$output" mode "$mode" >/dev/null 2>&1; then
        unset NIRI_SOCKET
        return 1
      fi

      log "set $output to $mode"
    }

    last_target=""
    last_socket=""

    while true; do
      if on_ac_power; then
        target="$ac_refresh"
      else
        target="$battery_refresh"
      fi

      if discover_niri_socket; then
        socket="$NIRI_SOCKET"
      else
        socket=""
      fi

      if [ "$socket" != "$last_socket" ]; then
        last_target=""
        last_socket="$socket"
      fi

      if [ "$target" != "$last_target" ]; then
        if apply_refresh "$target"; then
          last_target="$target"
        fi
      fi

      sleep "$poll_interval"
    done
  '';
in {
  options.modules.niri.dynamicRefreshRate = {
    enable = mkEnableOption "dynamic niri output refresh rate based on AC power";

    output = mkOption {
      type = types.str;
      description = "Niri output name whose refresh rate should follow AC power state.";
      example = "eDP-2";
    };

    acRefreshRate = mkOption {
      type = types.number;
      default = 120;
      description = "Target refresh rate in Hz while connected to AC power.";
    };

    batteryRefreshRate = mkOption {
      type = types.number;
      default = 60;
      description = "Target refresh rate in Hz while running on battery.";
    };

    pollInterval = mkOption {
      type = types.ints.positive;
      default = 5;
      description = "Polling interval in seconds for AC power state changes.";
    };
  };

  config = mkIf (config.modules.niri.enable && cfg.enable) {
    systemd.user.services.niri-dynamic-refresh-rate = {
      Unit = {
        Description = "Adjust niri refresh rate based on AC power";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = toString refreshScript;
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
