{...}: {
  home.stateVersion = "25.11";
  imports = [
    ./packages.nix
    ./stylix.nix
    ./wayland.nix
    ./wlsunset.nix
    ./xdg-hidden-apps.nix
    ./hyprland
    ./emacs
    ./ghostty
    ./git
    ./ashell
    ./dunst
    ./starship
    ./waybar
    ./vicinae
    ./watershot
    ./zsh
    ./zen-browser
    ./direnv
    ./zed-editor
    ./nvim
    ./zellij
    ./niri
  ];
}
