{
  config,
  lib,
  vars,
  pkgs,
  ...
}:
let
  cfg = config.syscfg.applications;
in
{
  options.syscfg.applications.neovim.enable = lib.mkOption {
    description = "Enables neovim configurations";
    type = lib.types.bool;
    default = true;
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.neovim.enable {
      environment.variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
      environment.systemPackages = [
        pkgs.nixd
        pkgs.prettierd
      ];
      home-manager.users."${vars.user}" =
        let
          inherit (config.home-manager.users."${vars.user}".xdg) configHome;
        in
        {
          programs.nixvim = {
            enable = true;
            colorscheme = "tokyonight-night";
            vimAlias = true;
            opts = {
              encoding = "utf-8";
              fileencoding = "utf-8";
              fileencodings = [ "utf-8" ];

              # Line number
              number = true;

              # Line width
              colorcolumn = [ 80 ];

              # Disable splash screen
              ruler = true;

              # Tabs
              expandtab = true;
              tabstop = 2;
              shiftwidth = 2;
              smartindent = true;

              # Automatically read file when updated
              autoread = true;

              # Backup dir
              backupdir = "${configHome}/.cache";
              directory = "${configHome}/.cache";

              # Undo file
              undofile = true;
              undodir = "${configHome}/nvim/vimundo";
              undolevels = 10000;
              undoreload = 10000;
            };
            plugins = {
              indent-blankline = {
                enable = true;
                settings.scope.enabled = false;
              };
              lsp = {
                enable = true;
                servers = {
                  nil_ls = {
                    enable = true;
                    settings = {
                      formatting.command = [ "${lib.getExe pkgs.nixfmt-rfc-style}" ];
                      nix.flake.autoArchive = false;
                    };
                    cmd = [ "nil" ];
                  };
                  cssls.enable = true;
                  html.enable = true;
                  jsonls.enable = true;
                };
              };
              none-ls = {
                enable = true;
                sources = {
                  diagnostics = {
                    deadnix.enable = true;
                    statix.enable = true;
                  };
                  code_actions.statix.enable = true;
                };
                enableLspFormat = false;
              };
              treesitter = {
                enable = true;
                settings.highlight.enable = true;
              };
              autoclose.enable = true;
              lualine.enable = true;
              lsp-format.enable = true;
              lsp-lines.enable = true;
              rainbow-delimiters.enable = true;
            };
            keymaps = [
              {
                mode = "n";
                key = "<leader>gg";
                action = "<cmd>LazyGit<CR>";
              }
            ];

            extraPlugins = with pkgs.vimPlugins; [
              vim-repeat

              # Theme
              tokyonight-nvim
            ];
          };
        };
    })
  ];
}
