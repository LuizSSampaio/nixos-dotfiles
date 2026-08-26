{ pkgs, ... }:
let
  gui = with pkgs; [
    nautilus
    pinta
    localsend
    qbittorrent
    mpv
    imv
    heroic
    prismlauncher
    gnome-disk-utility
    vial
    kdePackages.kdenlive
    kdePackages.ark
    mumble
    cinny-desktop
    easyeffects
    blender
  ];
  cli = with pkgs; [
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
    yazi
    gnupg
  ];
  dev = with pkgs; [
    opencode
    forgejo-cli
    wakatime-cli
    nodejs_26
  ];
in
{
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
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/luiz/nixos-dotfiles";
  };
}
