{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.system.steam;
in
{
  options.modules.system.steam = {
    enable = mkEnableOption "steam";
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;

      remotePlay.openFirewall = true;

      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      steam-run
    ];
  };
}
