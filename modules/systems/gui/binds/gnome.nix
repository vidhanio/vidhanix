{ lib, ... }:
{
  flake.aspects.binds.homeManager =
    { config, ... }:
    let

      bindType = lib.types.submodule (
        { config, options, ... }:
        {
          options.gnome = {
            enable = lib.mkEnableOption "this bind for GNOME" // {
              default = true;
            };

            wm = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "GNOME window-manager action run by the bind.";
            };

            cmd = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Command run by the GNOME bind.";
            };
          };

          config.gnome.cmd = lib.mkMerge [
            (lib.mkIf (config.cmd != null) (lib.mkDerivedConfig options.cmd lib.id))
            (lib.mkIf (config.app != null) (lib.mkDerivedConfig options.app lib.id))
          ];
        }
      );

      enabledBinds = lib.filterAttrs (
        _: bind: bind.gnome.enable && (bind.gnome.wm != null || bind.gnome.cmd != null)
      ) config.binds;

      normalizeKey =
        key:
        let
          modifiers = {
            SUPER = "<Super>";
            SHIFT = "<Shift>";
            CTRL = "<Control>";
            ALT = "<Alt>";
          };
        in
        lib.concatStringsSep "" (map (part: modifiers.${part} or part) (lib.splitString " + " key));

      wmBinds = lib.filterAttrs (_: bind: bind.gnome.wm != null) enabledBinds;
      cmdBinds = lib.filterAttrs (_: bind: bind.gnome.wm == null && bind.gnome.cmd != null) enabledBinds;

      wmSettings = {
        "org/gnome/desktop/wm/keybindings" = lib.mapAttrs' (
          keys: bind: lib.nameValuePair bind.gnome.wm [ (normalizeKey keys) ]
        ) wmBinds;
      };

      cmdSettings = lib.imap0 (
        i: keys:
        let
          bind = cmdBinds.${keys};
          cmdPath = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString i}/";
        in
        {
          "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [ cmdPath ];
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString i}" = {
            name = "Custom bind ${keys}";
            binding = normalizeKey keys;
            command = bind.gnome.cmd;
          };
        }
      ) (lib.attrNames cmdBinds);
    in
    {
      options.binds = lib.mkOption {
        type = lib.types.attrsOf bindType;
      };

      config.dconf.settings = lib.mkMerge ([ wmSettings ] ++ cmdSettings);
    };
}
