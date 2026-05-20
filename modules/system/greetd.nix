{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.system.greetd;
  username = "luiz";

  sessionCommand =
    {
      niri = "niri-session";
      hyprland = "start-hyprland";
    }
    .${cfg.session};
  desktopName =
    {
      niri = "niri";
      hyprland = "Hyprland";
    }
    .${cfg.session};
  sessionEnvironment = "${pkgs.coreutils}/bin/env XDG_CURRENT_DESKTOP=${desktopName} XDG_SESSION_DESKTOP=${desktopName} XDG_SESSION_TYPE=wayland";
in
{
  options.modules.system.greetd = {
    enable = mkEnableOption "greetd display manager";

    session = mkOption {
      type = types.enum [
        "niri"
        "hyprland"
      ];
      default = "niri";
      description = "Which Wayland compositor session to start (niri or hyprland)";
    };
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        initial_session = {
          command = "${sessionEnvironment} ${sessionCommand}";
          user = "${username}";
        };
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time --cmd '${sessionEnvironment} ${sessionCommand}'";
          user = "greeter";
        };
      };
    };
  };
}
