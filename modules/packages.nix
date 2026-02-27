{pkgs, ...}: let
  gui = with pkgs; [
    bitwarden-desktop
    mission-center
    nautilus
    pinta
    gnome-calculator
    gnome-disk-utility
    localsend
    qbittorrent
    mpv
    imv
    heroic
    prismlauncher
    gnome-disk-utility
    vial
    kdePackages.kdenlive
  ];
  cli = with pkgs; [
    bitwarden-cli
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
  dev = with pkgs; [
    opencode
  ];
in {
  home = {
    packages = gui ++ cli ++ dev;
  };

  services.flatpak.packages = [
    rec {
      appId = "com.hypixel.HytaleLauncher";
      sha256 = "1qv57dxbgi5mq4mqiy9p43irl9s2dhj0w227wyrdf0jbncrz8wvf";
      bundle = "${pkgs.fetchurl {
        url = "https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-latest.flatpak";
        inherit sha256;
      }}";
    }
    "in.cinny.Cinny"
    "com.rtosta.zapzap"
    "im.riot.Riot"
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/luiz/nixos-dotfiles";
  };
}
