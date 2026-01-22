{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib; let
  inherit (config.lib.stylix) colors;
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
              location = "file:${inputs.zjstatus.packages.${pkgs.system}.default}/bin/zjstatus.wasm";
            };
            _children = [
              {
                hide_frame_for_single_pane = true;

                format_left = "{mode} #[fg=#${colors.base0D},bold]{session}";
                format_center = "{tabs}";
                format_right = "{command_git_branch}";
                format_space = "";

                border_enabled = false;
                border_char = "─";
                border_format = "#[fg=#${colors.base03}]{char}";
                border_position = "top";

                mode_normal = "#[bg=#${colors.base0D},fg=#${colors.base00},bold] NORMAL ";
                mode_locked = "#[bg=#${colors.base03},fg=#${colors.base00},bold] LOCKED ";
                mode_resize = "#[bg=#${colors.base0A},fg=#${colors.base00},bold] RESIZE ";
                mode_pane = "#[bg=#${colors.base0D},fg=#${colors.base00},bold] PANE ";
                mode_tab = "#[bg=#${colors.base0B},fg=#${colors.base00},bold] TAB ";
                mode_scroll = "#[bg=#${colors.base0E},fg=#${colors.base00},bold] SCROLL ";
                mode_enter_search = "#[bg=#${colors.base0A},fg=#${colors.base00},bold] SEARCH ";
                mode_search = "#[bg=#${colors.base0A},fg=#${colors.base00},bold] SEARCH ";
                mode_rename_tab = "#[bg=#${colors.base0A},fg=#${colors.base00},bold] RENAME ";
                mode_rename_pane = "#[bg=#${colors.base0A},fg=#${colors.base00},bold] RENAME ";
                mode_session = "#[bg=#${colors.base0E},fg=#${colors.base00},bold] SESSION ";
                mode_move = "#[bg=#${colors.base0E},fg=#${colors.base00},bold] MOVE ";
                mode_prompt = "#[bg=#${colors.base0D},fg=#${colors.base00},bold] PROMPT ";
                mode_tmux = "#[bg=#${colors.base09},fg=#${colors.base00},bold] TMUX ";

                tab_normal = "#[fg=#${colors.base03}] {name} ";
                tab_normal_fullscreen = "#[fg=#${colors.base03}] {name} [] ";
                tab_normal_sync = "#[fg=#${colors.base03}] {name} <> ";
                tab_active = "#[fg=#${colors.base0D},bold,italic] {name} ";
                tab_active_fullscreen = "#[fg=#${colors.base0D},bold,italic] {name} [] ";
                tab_active_sync = "#[fg=#${colors.base0D},bold,italic] {name} <> ";

                command_git_branch_command = "git rev-parse --abbrev-ref HEAD";
                command_git_branch_format = "#[fg=#${colors.base0D}] {stdout} ";
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
                  _children = [
                    {
                      plugin = {
                        location = "zjstatus";
                      };
                    }
                  ];
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
