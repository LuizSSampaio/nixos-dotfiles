{ hyprland, pkgs, system, inputs, ...}: {

  imports = [
    hyprland.homeManagerModules.default
    ./programs
  ];

  home = {
    username = "luiz";
    homeDirectory = "/home/luiz";
  };

  home.packages = (with pkgs; [
    # Desktop Enviroment
    kitty
    rofi

    # Development
    neovim
    vscode
    gcc
    rustup

    # Applications
    vesktop
    inputs.zen-browser.packages."${system}".specific

    # Utils
    yazi
    eza
    fzf
    curl
    wget
    fastfetch
    zoxide
    stow
    zip
    unzip

    # Theme
    dconf2nix
  ]) ++ (with pkgs.gnome; [
    nautilus
    gnome-tweaks
  ]);
    
  programs.home-manager.enable = true;

  home.stateVersion = "24.05";
}
