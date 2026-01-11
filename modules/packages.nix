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
    imv
    vesktop
    heroic
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
    eza
    impala
    bluetui
    wiremix
    yazi
  ];
  dev = with pkgs; [ cmake gcc gnumake opencode ];
in { home = { packages = gui ++ cli ++ dev; }; }
