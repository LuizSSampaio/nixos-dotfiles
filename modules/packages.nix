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
    gnome-disk-utility
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
  dev = with pkgs; [ cmake gcc gnumake opencode ispell ];
in {
  home = { packages = gui ++ cli ++ dev; };

  services.flatpak.packages = [
    rec {
      appId = "com.hypixel.HytaleLauncher";
      sha256 = "1qv57dxbgi5mq4mqiy9p43irl9s2dhj0w227wyrdf0jbncrz8wvf";
      bundle = "${pkgs.fetchurl {
        url = "https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-latest.flatpak";
        inherit sha256;
      }}";
    }
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/luiz/nixos-dotfiles";
  };
}
