{...}: {
  home.stateVersion = "25.11";
  imports = [
    ./packages.nix
    ./stylix.nix
    ./wayland.nix
    ./wlsunset.nix
    ./xdg-hidden-apps.nix
    ./hyprlock
    ./hypridle
    ./hyprland
    ./emacs
    ./ghostty
    ./git
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
