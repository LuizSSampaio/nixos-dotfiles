{ pkgs, ...}: let
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
    # obsidian  # temporarily disabled - build failing
    prismlauncher
  ];
  cli = with pkgs; [
    _1password-cli
    atuin
    fastfetch
    ffmpeg
    ripgrep
    bat
    fd
    fzf
    zoxide
    eza
  ];
  dev = with pkgs; [
    cmake
    gcc
    gnumake
    opencode
  ];
in {
  home = {
    packages = gui ++ cli ++ dev;
  };
}
