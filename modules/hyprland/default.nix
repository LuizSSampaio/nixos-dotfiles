{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.hyprland;
in {
  imports = [
    ./autostart.nix
    ./bindings.nix
    ./env.nix
    ./input.nix
    ./looknfeel.nix
    ./windows.nix
  ];

  options.modules.hyprland = {
    enable = mkEnableOption "hyprland window manager";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard hyprland
    ];

    wayland.windowManager.hyprland.enable = true;
    wayland.windowManager.hyprland.systemd.variables = ["--all"];

    services.hyprpolkitagent.enable = true;
  };
}
