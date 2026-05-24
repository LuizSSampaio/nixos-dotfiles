{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  inherit (config.lib.stylix) colors;
  cfg = config.modules.tmux;
in
{
  options.modules.tmux = {
    enable = mkEnableOption "tmux terminal multiplexer";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
    ];

    programs.tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      escapeTime = 10;
      keyMode = "vi";
      mouse = true;
      terminal = "tmux-256color";

      extraConfig = ''
        set -g focus-events on
        set -g renumber-windows on
        set -g set-clipboard on
        set -ga terminal-overrides ",tmux-256color:Tc"

        # Match Neovim's pane navigation while letting nvim handle its own splits.
        bind-key -n C-h if-shell "ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(n?vim|vimdiff|nvimdiff)$'" "send-keys C-h" "select-pane -L"
        bind-key -n C-j if-shell "ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(n?vim|vimdiff|nvimdiff)$'" "send-keys C-j" "select-pane -D"
        bind-key -n C-k if-shell "ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(n?vim|vimdiff|nvimdiff)$'" "send-keys C-k" "select-pane -U"
        bind-key -n C-l if-shell "ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(n?vim|vimdiff|nvimdiff)$'" "send-keys C-l" "select-pane -R"
        bind-key -T copy-mode-vi C-h select-pane -L
        bind-key -T copy-mode-vi C-j select-pane -D
        bind-key -T copy-mode-vi C-k select-pane -U
        bind-key -T copy-mode-vi C-l select-pane -R

        bind-key c new-window -c "#{pane_current_path}"
        bind-key '"' split-window -v -c "#{pane_current_path}"
        bind-key % split-window -h -c "#{pane_current_path}"
        bind-key H previous-window
        bind-key L next-window

        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"

        # Rectangular bottom bar using Stylix colors; no rounded separators.
        set -g status on
        set -g status-position bottom
        set -g status-justify left
        set -g status-interval 5
        set -g status-style "bg=#${colors.base00},fg=#${colors.base05}"
        set -g status-left-length 48
        set -g status-left "#[bg=#${colors.base0D},fg=#${colors.base00},bold] #S #[bg=#${colors.base01},fg=#${colors.base05}] "
        set -g status-right "#[bg=#${colors.base00},fg=#${colors.base04}] %Y-%m-%d #[fg=#${colors.base0D},bold]%H:%M "
        set -g window-status-separator ""
        set -g window-status-format "#[bg=#${colors.base01},fg=#${colors.base04}] #I:#W "
        set -g window-status-current-format "#[bg=#${colors.base0B},fg=#${colors.base00},bold] #I:#W "

        set -g pane-border-status bottom
        set -g pane-border-format "#[fg=#${colors.base0D},bold] #{pane_index} #[fg=#${colors.base04}]#{pane_current_command} "
        set -g pane-border-style "fg=#${colors.base03}"
        set -g pane-active-border-style "fg=#${colors.base0D}"
        set -g message-style "bg=#${colors.base0D},fg=#${colors.base00},bold"
        set -g mode-style "bg=#${colors.base0D},fg=#${colors.base00},bold"
      '';
    };
  };
}
