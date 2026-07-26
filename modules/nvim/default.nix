{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.nvim;
in {
  options.modules.nvim = {
    enable = mkEnableOption "nvim";
  };

  config = mkIf cfg.enable {
    programs.nvf = {
      enable = true;

      settings.vim = {
        additionalRuntimePaths = [./templates];

        options = {
          shiftwidth = 4;
          tabstop = 4;
          scrolloff = 5;
        };

        keymaps = [
          {
            key = "<leader>bd";
            mode = "n";
            action = "<Cmd>Bdelete<CR>";
            silent = true;
            desc = "Close buffer";
          }
          {
            key = "H";
            mode = "n";
            action = "<Cmd>BufferLineCyclePrev<CR>";
            silent = true;
            desc = "Previous buffer";
          }
          {
            key = "L";
            mode = "n";
            action = "<Cmd>BufferLineCycleNext<CR>";
            silent = true;
            desc = "Next buffer";
          }

          {
            key = "<leader>e";
            mode = "n";
            action = "<Cmd>Oil<CR>";
            silent = true;
            desc = "Open Oil [oil.nvim]";
          }

          {
            key = "<leader>gd";
            mode = "n";
            action = "<Cmd>DiffviewOpen<CR>";
            silent = true;
            desc = "Open Diff View [diffview.nvim]";
          }
          {
            key = "<leader>gD";
            mode = "n";
            action = "<Cmd>DiffviewClose<CR>";
            silent = true;
            desc = "Close Diff View [diffview.nvim]";
          }

          {
            key = "<leader>rr";
            mode = "n";
            action = "<Cmd>RunFile<CR>";
            silent = true;
            desc = "Run File [run-nvim]";
          }
          {
            key = "<leader>rR";
            mode = "n";
            action = "<Cmd>RunLast<CR>";
            silent = true;
            desc = "Run Last [run-nvim]";
          }
        ];

        spellcheck = {
          enable = true;
          programmingWordlist.enable = true;
        };

        lsp = {
          enable = true;

          formatOnSave = true;
          trouble.enable = true;
          otter-nvim.enable = true;
          nvim-docs-view.enable = true;
          harper-ls.enable = true;

          servers.clangd = {
            cmd = lib.mkForce [
              "${pkgs.clang-tools}/bin/clangd"
              "-j=12"
              "--background-index"
              "--clang-tidy"
              "--completion-style=detailed"
              "--header-insertion=iwyu"
              "--header-insertion-decorators"
              "--log=error"
            ];

            init_options = {
              fallbackFlags = ["-std=c++23"];
            };
          };
        };

        diagnostics = {
          enable = true;
          config = {
            signs = true;
            update_in_insert = true;
            virtual_text = true;
          };
        };

        debugger = {
          nvim-dap = {
            enable = true;
            ui.enable = true;
          };
        };

        languages = {
          enableDAP = true;
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          nix.enable = true;
          markdown.enable = true;
          bash.enable = true;
          clang.enable = true;
          cmake.enable = true;
          json.enable = true;
          lua.enable = true;
          typst.enable = true;
          ts.enable = false;
          just.enable = true;
          java.enable = false;
          rust = {
            enable = true;
            extensions.crates-nvim.enable = true;
          };
          toml.enable = true;
          glsl.enable = true;
          wgsl.enable = true;
        };

        visuals = {
          nvim-scrollbar.enable = true;
          nvim-web-devicons.enable = true;
          nvim-cursorline.enable = true;
          cinnamon-nvim.enable = true;
          fidget-nvim.enable = true;

          highlight-undo.enable = true;
          indent-blankline = {
            enable = true;
            setupOpts = {
              scope.enabled = true;
              indent.char = "│";
            };
          };
        };

        statusline.lualine = {
          enable = true;
          componentSeparator = {
            left = "";
            right = "";
          };
          sectionSeparator = {
            left = "";
            right = "";
          };
        };

        theme.enable = true;

        autopairs.nvim-autopairs.enable = true;

        autocomplete.blink-cmp.enable = true;

        snippets.luasnip.enable = true;

        filetree = {
          neo-tree = {
            enable = false;
          };
        };

        tabline = {
          nvimBufferline.enable = true;
        };

        treesitter.context.enable = true;

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        };

        telescope.enable = true;

        git = {
          enable = true;
          gitsigns.enable = true;
          gitsigns.codeActions.enable = false;
          neogit.enable = false;
        };

        dashboard = {
          alpha.enable = true;
        };

        notify = {
          nvim-notify.enable = true;
        };

        projects = {
          project-nvim.enable = true;
        };

        clipboard = {
          enable = true;
          providers.wl-copy.enable = true;
          registers = "unnamedplus";
        };

        runner.run-nvim.enable = true;

        utility = {
          diffview-nvim.enable = true;
          yanky-nvim = {
            enable = true;
            setupOpts.ring.storage = "sqlite";
          };
          surround.enable = true;
          multicursors.enable = true;
          smart-splits.enable = true;
          undotree.enable = true;
          nvim-biscuits.enable = true;
          direnv.enable = true;
          snacks-nvim.enable = true;
          new-file-template.enable = true;
          yazi-nvim.enable = true;
          vim-wakatime.enable = true;
          crazy-coverage.enable = true;
          oil-nvim.enable = true;

          preview.glow.enable = true;

          motion = {
            hop.enable = true;
            leap.enable = true;
            precognition.enable = true;
          };
        };

        notes = {
          todo-comments.enable = true;
        };

        terminal = {
          toggleterm = {
            enable = true;
            lazygit.enable = true;
          };
        };

        ui = {
          borders.enable = true;
          noice.enable = true;
          colorizer.enable = true;
          illuminate.enable = true;
          breadcrumbs = {
            enable = true;
            navbuddy.enable = true;
          };
          smartcolumn = {
            enable = true;
          };
          fastaction.enable = true;
        };

        assistant = {
          codecompanion-nvim.enable = true;
        };

        comments = {
          comment-nvim.enable = true;
        };
      };
    };
  };
}
