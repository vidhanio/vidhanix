{
  flake.aspects.nixvim = {
    nixvim = {
      plugins.mini.modules.files = { };

      keymaps = [
        {
          key = "<leader>e";
          action.__raw = ''
            function()
              local path = vim.api.nvim_buf_get_name(0)
              require("mini.files").open(path ~= "" and path or nil)
            end
          '';
          mode = "n";
          options = {
            silent = true;
            desc = "File Explorer";
          };
        }
      ];
    };
  };
}
