{
  lib,
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.nixvim.nixosModules.nixvim ];
  config = {
    programs.nixvim = {
      enable = true;
      enableMan = false;
      vimAlias = true;
      luaLoader.enable = true;
      opts = {
        foldmethod = "manual";
        number = true;
        showmode = false;
        shiftwidth = 2;
        smartindent = true;
        undofile = true;
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
      colorschemes.nord.enable = true;
      defaultEditor = true;
    };
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
