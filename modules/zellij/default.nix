{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.zellij;

  zellij-forgot = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "zellij-forgot";
    version = "0.4.2";
    src = pkgs.fetchurl {
      url = "https://github.com/karimould/zellij-forgot/releases/download/${version}/zellij_forgot.wasm";
      hash = "sha256-H5N8cA65vo8ganQHlLHLgvVxS+kQPQOXodYgnLmjWWk=";
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/zellij_forgot.wasm
    '';
  };
in {
  options.modules.zellij = {
    enable = mkEnableOption "zellij";
  };

  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        show_startup_tips = false;
        simplified_ui = true;
        copy_on_select = true;
        default_layout = "default";

        plugins = {
          zjstatus = {
            _props = {
              location = "file:${
                inputs.zjstatus.packages.${pkgs.system}.default
              }/bin/zjstatus.wasm";
            };
            _children = [
              {
                hide_frame_for_single_pane = true;

                format_left = "{mode} #[fg=#89B4FA,bold]{session}";
                format_center = "{tabs}";
                format_right = "{command_git_branch}";
                format_space = "";

                border_enabled = false;
                border_char = "─";
                border_format = "#[fg=#6C7086]{char}";
                border_position = "top";

                mode_normal = "#[bg=#89B4FA,fg=#1E1E2E,bold] NORMAL ";
                mode_locked = "#[bg=#6C7086,fg=#1E1E2E,bold] LOCKED ";
                mode_resize = "#[bg=#F9E2AF,fg=#1E1E2E,bold] RESIZE ";
                mode_pane = "#[bg=#89B4FA,fg=#1E1E2E,bold] PANE ";
                mode_tab = "#[bg=#A6E3A1,fg=#1E1E2E,bold] TAB ";
                mode_scroll = "#[bg=#F5C2E7,fg=#1E1E2E,bold] SCROLL ";
                mode_enter_search = "#[bg=#F9E2AF,fg=#1E1E2E,bold] SEARCH ";
                mode_search = "#[bg=#F9E2AF,fg=#1E1E2E,bold] SEARCH ";
                mode_rename_tab = "#[bg=#F9E2AF,fg=#1E1E2E,bold] RENAME ";
                mode_rename_pane = "#[bg=#F9E2AF,fg=#1E1E2E,bold] RENAME ";
                mode_session = "#[bg=#CBA6F7,fg=#1E1E2E,bold] SESSION ";
                mode_move = "#[bg=#F5C2E7,fg=#1E1E2E,bold] MOVE ";
                mode_prompt = "#[bg=#89B4FA,fg=#1E1E2E,bold] PROMPT ";
                mode_tmux = "#[bg=#FAB387,fg=#1E1E2E,bold] TMUX ";

                tab_normal = "#[fg=#6C7086] {name} ";
                tab_normal_fullscreen = "#[fg=#6C7086] {name} [] ";
                tab_normal_sync = "#[fg=#6C7086] {name} <> ";
                tab_active = "#[fg=#89B4FA,bold,italic] {name} ";
                tab_active_fullscreen = "#[fg=#89B4FA,bold,italic] {name} [] ";
                tab_active_sync = "#[fg=#89B4FA,bold,italic] {name} <> ";

                command_git_branch_command = "git rev-parse --abbrev-ref HEAD";
                command_git_branch_format = "#[fg=blue] {stdout} ";
                command_git_branch_interval = "10";
                command_git_branch_rendermode = "static";
              }
            ];
          };
        };
      };

      layouts = {
        default = {
          layout = {
            _children = [
              {
                pane = {
                  _props = {
                    name = "";
                  };
                };
              }
              {
                pane = {
                  _props = {
                    size = 1;
                    borderless = true;
                  };
                  _children = [{plugin = {location = "zjstatus";};}];
                };
              }
            ];
          };
        };
      };

      extraConfig = ''
        keybinds {
            shared_except "locked" {
                bind "Ctrl y" {
                    LaunchOrFocusPlugin "file:${zellij-forgot}/bin/zellij_forgot.wasm" {
                        floating true
                    }
                }
            }
        }
      '';
    };
  };
}
