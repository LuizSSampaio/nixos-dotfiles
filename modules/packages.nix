{ pkgs, ... }:
let
  gui = with pkgs; [
    _1password-gui
    mission-center
    nautilus
    pinta
    gnome-calculator
    gnome-disk-utility
    localsend
    qbittorrent
    mpv
    heroic
    obsidian
    prismlauncher
  ];
  cli = with pkgs; [
    _1password-cli
    atuin
    btop
    unzip
    zip
    fastfetch
    ffmpeg
    ripgrep
    bat
    fd
    fzf
    zoxide
    eza
    impala
    bluetui
    wiremix
  ];
  dev = with pkgs; [ cmake gcc gnumake opencode gh ];
in { home = { packages = gui ++ cli ++ dev; }; }
