{ ... }: {
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
    ./ghostty
    ./kitty
    ./git
    ./starship
    ./zsh
    ./zen-browser
    ./direnv
    ./zed-editor
    ./nvim
    ./tmux
    ./zellij
    ./niri
    ./obs-studio
    ./emacs
    ./noctalia
    ./sops
    ./opencode
  ];
}
