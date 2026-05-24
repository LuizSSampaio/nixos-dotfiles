{...}: {
  imports = [../../modules/default.nix];

  config.modules = {
    hypridle.enable = true;
    niri = {
      enable = true;
      dynamicRefreshRate = {
        enable = true;
        output = "eDP-1";
        acRefreshRate = 120.001;
        batteryRefreshRate = 60.001;
      };
      monitors = [
        {
          name = "eDP-1";
          scale = 2.0;
        }
        {
          name = "HDMI-A-1";
          width = 1920;
          height = 1080;
          refresh = 239.997;
          x = -1920;
        }
      ];
    };
    kitty.enable = true;
    git.enable = true;
    starship.enable = true;
    zsh.enable = true;
    zen-browser.enable = true;
    direnv.enable = true;
    nvim.enable = true;
    tmux.enable = true;
    obs-studio.enable = true;
    noctalia.enable = true;
  };
}
