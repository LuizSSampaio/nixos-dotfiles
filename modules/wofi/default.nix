{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.wofi;
in {
  options.modules.wofi = { enable = mkEnableOption "wofi"; };

  config = mkIf cfg.enable {
    programs.wofi = {
      enable = true;
      settings = {
        width = 600;
        height = 350;
        location = "center";
        show = "drun";
        prompt = "Search...";
        filter_rate = 100;
        allow_markup = true;
        no_actions = true;
        halign = "fill";
        orientation = "vertical";
        content_halign = "fill";
        insensitive = true;
        allow_images = true;
        image_size = 40;
        gtk_dark = true;
      };
    };
  };
}
