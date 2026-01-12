{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.system.plymouth;
in {
  options.modules.system.plymouth = {
    enable = mkEnableOption "Plymouth boot splash";
  };

  config = mkIf cfg.enable {
    # Enable Plymouth boot splash
    boot.plymouth.enable = true;

    # CRITICAL: Enable systemd in initrd for graphical LUKS password prompts
    # This is required for Plymouth to show a graphical password entry
    # instead of falling back to text mode during disk decryption
    boot.initrd.systemd.enable = true;

    # Silent boot configuration for a clean boot experience
    boot.consoleLogLevel = 0;
    boot.initrd.verbose = false;

    boot.kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    # Stylix Plymouth theming (NixOS system-level)
    # This applies Gruvbox colors from your Stylix config to the boot splash
    stylix.targets.plymouth = {
      enable = true;
      # NixOS snowflake logo (has rotational symmetry, animation looks good)
      logo = pkgs.nixos-icons
        + "/share/icons/hicolor/256x256/apps/nix-snowflake.png";
      logoAnimated = true;
    };
  };
}
