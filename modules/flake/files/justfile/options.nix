{
  flake-parts-lib,
  lib,
  ...
}:
let
  renderRecipe =
    name: recipe:
    let
      doc = lib.optionalString (recipe.doc != "") "# ${recipe.doc}\n";
      attrs = lib.concatMapStringsSep "" (attr: "[${attr}]\n") recipe.attrs;
      args = lib.optionalString (recipe.args != [ ]) " ${lib.concatStringsSep " " recipe.args}";
      deps = lib.optionalString (
        recipe.dependencies != [ ]
      ) " ${lib.concatStringsSep " " recipe.dependencies}";
      body = lib.optionalString (recipe.body != "") (
        "\n"
        + lib.concatMapStringsSep "\n" (line: "    ${line}") (
          lib.splitString "\n" (lib.removeSuffix "\n" recipe.body)
        )
      );
    in
    doc + attrs + lib.optionalString recipe.silent "@" + name + args + ":" + deps + body;

  renderJustfile =
    {
      settings,
      vars,
      order,
      recipes,
      mods ? [ ],
      ...
    }:
    lib.concatStringsSep "\n\n" (
      lib.filter (section: section != "") [
        (lib.concatMapStringsSep "\n" (setting: "set ${setting}") settings)
        (lib.concatMapStringsSep "\n" (mod: "mod ${mod}") mods)
        (lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name} := ${value}") vars))
        (lib.concatStringsSep "\n\n" (map (name: renderRecipe name recipes.${name}) order))
      ]
    )
    + "\n";

  justfileSubmodule = {
    options = {
      settings = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Settings to declare at the top of the justfile, e.g. `no-cd`.";
        default = [ ];
      };

      vars = lib.mkOption {
        type = lib.types.attrsOf lib.types.lines;
        description = "Variables to declare in the justfile.";
        default = { };
      };

      order = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "The order of recipes in the justfile.";
        default = [ ];
      };

      recipes = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              doc = lib.mkOption {
                type = lib.types.str;
                description = "Documentation comment shown by `just --list`.";
                default = "";
              };
              attrs = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                description = ''
                  Attributes to apply to the recipe, rendered as `[attr]`
                  lines above it. For example, `attrs = [ "private" ]`
                  hides the recipe from `just --list` and prevents direct
                  invocation; it remains usable as a dependency. See
                  <https://just.systems/man/en/attributes.html>.
                '';
                default = [ ];
              };
              args = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                description = "Recipe parameters.";
                default = [ ];
              };
              dependencies = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                description = "Dependencies of the recipe, either names or calls.";
                default = [ ];
              };
              silent = lib.mkOption {
                type = lib.types.bool;
                description = "Prefix the recipe with `@`, so just does not echo its commands.";
                default = false;
              };
              body = lib.mkOption {
                type = lib.types.lines;
                description = "The recipe body.";
                default = "";
              };
            };
          }
        );
        description = "Recipes to define in the justfile.";
        default = { };
      };
    };
  };
in
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, ... }:
    let
      cfg = config.justfile;
    in
    {
      options.justfile = justfileSubmodule.options // {
        modules = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule justfileSubmodule);
          description = "Submodules to generate alongside the justfile, e.g. `eval.just`.";
          default = { };
        };

        rendered = lib.mkOption {
          type = lib.types.str;
          description = "The rendered justfile content.";
          readOnly = true;
          default = renderJustfile (cfg // { mods = lib.attrNames cfg.modules; });
        };
      };

      config = {
        files.commentedFile =
          lib.mapAttrs' (
            name: module: lib.nameValuePair "${name}.just" { text = renderJustfile module; }
          ) cfg.modules
          // {
            "justfile".text = cfg.rendered;
          };
      };
    }
  );
}
