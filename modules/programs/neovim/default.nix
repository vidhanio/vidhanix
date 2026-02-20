{ inputs, config, ... }:
{
  flake-file.inputs.nixvim.url = "github:nix-community/nixvim";

  flake.modules = {
    nixos.default = {
      imports = [ inputs.nixvim.nixosModules.default ];

      programs.nixvim.imports = [ config.flake.modules.nixvim.default ];
    };
    homeManager.default = {
      imports = [ inputs.nixvim.homeModules.default ];

      programs.nixvim.imports = [ config.flake.modules.nixvim.default ];
    };
    nixvim.default = {
      enable = true;
      viAlias = true;
      clipboard = {
        register = "unnamedplus";
        providers.wl-copy.enable = true;
      };

      lsp = {
        enable = true;
        servers = {
          # keep-sorted start block=yes
          nil_ls.enable = true;
          ruff.enable = true;
          rust-analyzer = {
            enable = true;
          };
          tailwindcss.enable = true;
          tinymist.enable = true;
          tombi.enable = true;
          ty.enable = true;
          yamlls.enable = true;
          # keep-sorted end
        };
      };

      plugins = {
        # keep-sorted start block=yes
        direnv.enable = true;
        lsp-format.enable = true;
        lspconfig.enable = true;
        none-ls = {
          enable = true;
          sources.formatting.treefmt.enable = true;
        };
        nvim-tree.enable = true;
        telescope.enable = true;
        wakatime.enable = true;
        web-devicons.enable = true;
        # keep-sorted end
      };
    };
  };
}
