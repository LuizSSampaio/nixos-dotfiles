{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.obs-studio;
  nvidia-lib-flag = ''
    --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
  '';
in
{
  options.modules.obs-studio = {
    enable = mkEnableOption "Obs Studio";
  };

  config = mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      package = pkgs.obs-studio.overrideAttrs (old: {
        preFixup = (old.preFixup or "") + ''
          wrapProgram $out/bin/obs \
            ${nvidia-lib-flag}
        '';
      });
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };
  };
}
