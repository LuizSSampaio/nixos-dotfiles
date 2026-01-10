{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.greetd;
  username = "luiz";
in {
  options.modules.greetd = {
    enable = mkEnableOption "greetd display manager";
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        initial_session = {
          command = "${config.desktopEnvironment.startCmd}";
          user = "${username}";
        };
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time -cmd ${config.desktopEnvironment.startCmd}";
          user = "greeter"
        };
      };
    };
  };
}
