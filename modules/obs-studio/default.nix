{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.obs-studio;
in {
  options.modules.obs-studio = {enable = mkEnableOption "Obs Studio";};

  config = mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-gstreamer
        obs-vkcapture
      ];
    };
  };
}
