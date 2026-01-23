{...}: {
  imports = [../../modules/default.nix];

  config.modules = {
    hyprland = {
      enable = false;
      monitors = [
        "eDP-2,highrr,auto,auto"
        "HDMI-A-1,highrr,auto-left,auto"
        ",preferred,auto,auto"
      ];
    };
    hyprlock.enable = true;
    niri = {
      enable = true;
      monitors = [
        {
          name = "eDP-2";
          scale = 2.0;
        }
        {
          name = "HDMI-A-1";
          x = -1920;
          refresh = 239.997;
        }
      ];
    };
    wlsunset = {
      enable = true;
      latitude = -20.4;
      longitude = -43.5;
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
    zellij.enable = true;
  };
}
