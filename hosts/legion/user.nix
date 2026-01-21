{
  config,
  lib,
  inputs,
  ...
}:

{
  imports = [ ../../modules/default.nix ];

  config.modules = {
    hyprland = {
      enable = true;
      monitors = [
        "eDP-2,highrr,auto,auto"
        "HDMI-A-1,highrr,auto-left,auto"
        ",preferred,auto,auto"
      ];
    };
    ghostty.enable = true;
    git.enable = true;
    dunst.enable = true;
    starship.enable = true;
    waybar.enable = true;
    watershot.enable = true;
    zsh.enable = true;
    vicinae.enable = true;
    zen-browser.enable = true;
    direnv.enable = true;
    nvim.enable = true;
  };
}
