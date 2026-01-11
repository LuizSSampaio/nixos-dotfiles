{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.system.fonts;
in {
  options.modules.system.fonts = { enable = mkEnableOption "custom fonts"; };

  config = mkIf cfg.enable {
    fonts = {
      fonts = with pkgs; [
        jetbrains-mono
        roboto
        openmoji-color
        nerd-fonts.jetbrains-mono
      ];

      fontconfig = {
        hinting.autohint = true;
        defaultFonts = { emoji = [ "OpenMoji Color" ]; };
      };
    };
  };
}
