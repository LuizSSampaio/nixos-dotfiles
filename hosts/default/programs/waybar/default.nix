{ config, lib, pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    systemd = {
      enable = false;
      target = "graphical-session.target";
    };
    settings = [{
        "layer" = "top";
	"position" = "top";
	modules-left = [
	  "custom/launcher"
	  "temperature"
	  "mpd"
	  "custom/cava-internal"
	];
	modules-center = [
	  "clock"
	];
	modules-right = [
	  "pulseaudio"
	  "backlight"
	  "memory"
	  "cpu"
	  "network"
	  "custom/powermenu"
	  "tray"
	];
      }];
  };
}
