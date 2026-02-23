{
  flake.modules.nixvim.default =
    { lib, ... }:
    let
      u = lib.nixvim.utils;
    in
    {
      plugins = {
        opencode = {
          enable = true;
          settings.auto_reload = true;
        };

        snacks.settings.picker = {
          enabled = true;
          actions.opencode_send.__raw = "function(...) return require('opencode').snacks_picker_send(...) end";
          win.input.keys."<a-a>" = u.listToUnkeyedAttrs [ "opencode_send" ] // {
            mode = [
              "n"
              "i"
            ];
          };
        };
      };

      keymaps = [
        {
          key = "<C-a>";
          action.__raw = "function() require('opencode').ask('@this: ', { submit = true }) end";
          mode = [
            "n"
            "x"
          ];
          options = {
            silent = true;
            desc = "Ask OpenCode";
          };
        }
        {
          key = "<C-x>";
          action.__raw = "function() require('opencode').select() end";
          mode = [
            "n"
            "x"
          ];
          options = {
            silent = true;
            desc = "OpenCode select";
          };
        }
        {
          key = "go";
          action.__raw = "function() return require('opencode').operator('@this ') end";
          mode = [
            "n"
            "x"
          ];
          options = {
            expr = true;
            silent = true;
            desc = "Add range to OpenCode";
          };
        }
        {
          key = "goo";
          action.__raw = "function() return require('opencode').operator('@this ') .. '_' end";
          mode = "n";
          options = {
            expr = true;
            silent = true;
            desc = "Add line to OpenCode";
          };
        }
      ];
    };
}
