{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.system.steam;
in {
  options.modules.system.steam = { enable = mkEnableOption "steam"; };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
  };
}
