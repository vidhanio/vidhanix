{
  inputs,
  ...
}:
{
  flake.modules.homeManager.default =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.programs.agents.skills;

      # Recursively discover directories containing `SKILL.md` under a source
      # root. A skill at the root itself gets the source name as its id;
      # nested skills use their `/`-separated relative path.
      discoverSource =
        name: source:
        let
          sourceRoot =
            if source.path != null then
              source.path
            else if source.input != null then
              if inputs ? ${source.input} then
                let
                  input = inputs.${source.input};
                in
                if builtins.isPath input then input else input.outPath
              else
                throw "programs.agents.skills: source ${name} refers to unknown input ${source.input}"
            else
              throw "programs.agents.skills: source ${name} must set `path` or `input`";
          root = "${sourceRoot}/${source.subdir}";

          maxDepth = source.filter.maxDepth or null;
          nameRegex = source.filter.nameRegex or null;
          idPrefix = source.idPrefix or null;

          assertSkillId =
            id:
            if lib.strings.hasPrefix "/" id || lib.strings.hasInfix ".." id then
              throw "programs.agents.skills: invalid skill id ${id} (must not start with '/' or contain '..')"
            else
              id;

          prefixSkillId =
            prefix: baseId:
            let
              checkedBaseId = assertSkillId baseId;
            in
            assertSkillId (
              if prefix == null || prefix == "" then checkedBaseId else "${assertSkillId prefix}/${checkedBaseId}"
            );

          scan =
            path: relParts: depth:
            let
              entries = builtins.readDir path;
              relPath = lib.concatStringsSep "/" relParts;
              hasSkill = entries ? "SKILL.md";
              include = hasSkill && (nameRegex == null || builtins.match nameRegex relPath != null);
              current = lib.optional include {
                id = prefixSkillId idPrefix (if relPath == "" then name else relPath);
                dir = path;
                inherit name;
              };

              dirs = lib.concatMap (
                n: if entries.${n} == "directory" || entries.${n} == "symlink" then [ n ] else [ ]
              ) (builtins.attrNames entries);

              effectiveMax = if maxDepth == null then 100 else maxDepth;
              deeper =
                if depth < effectiveMax then
                  lib.concatMap (n: scan (path + "/${n}") (relParts ++ [ n ]) (depth + 1)) dirs
                else
                  [ ];
            in
            current ++ deeper;
        in
        if !builtins.pathExists root then
          throw "programs.agents.skills: source ${name} subdir ${root} does not exist"
        else
          lib.listToAttrs (
            map (skill: {
              name = skill.id;
              value = skill;
            }) (scan root [ ] 0)
          );

      # Merge per-source catalogs, enforcing unique ids.
      discoverCatalog =
        sources:
        let
          addSource =
            acc: name: source:
            lib.foldlAttrs (
              inner: id: skill:
              if inner ? ${id} then
                throw "programs.agents.skills: duplicate skill id '${id}' in source '${skill.source}' and source '${inner.${id}.source}'"
              else
                inner
                // {
                  ${id} = skill;
                }
            ) acc (discoverSource name source);
        in
        lib.foldlAttrs addSource { } sources;

      catalog = discoverCatalog cfg.sources;

      # Allowlist from enableAll + explicit enable list (upstream selection logic).
      allowlistFor =
        {
          enableAll ? false,
          enable ? [ ],
        }:
        let
          enableAllSources = if builtins.isList enableAll then enableAll else [ ];
          enableAllAllSources = if builtins.isBool enableAll then enableAll else false;
          sourceAllowlist = lib.concatMap (
            sourceName: builtins.attrNames (lib.filterAttrs (_: skill: skill.name == sourceName) catalog)
          ) enableAllSources;
        in
        lib.unique (
          (if enableAllAllSources then builtins.attrNames catalog else [ ]) ++ sourceAllowlist ++ enable
        );

      selected = allowlistFor { inherit (cfg.skills) enableAll enable; };

      selectedSkills = lib.listToAttrs (
        map (
          id:
          if catalog ? ${id} then
            lib.nameValuePair id catalog.${id}
          else
            throw "programs.agents.skills: skills.enable refers to unknown skill ${id}"
        ) selected
      );

      dest = cfg.targets.agents.path;

      # Inline skills, mirroring the `skills` option of the agent harnesses.
      mkSkillEntry =
        name: content:
        let
          dir = "${dest}/${name}";
        in
        if builtins.isPath content && lib.pathIsDirectory content then
          lib.nameValuePair dir {
            source = content;
            recursive = true;
          }
        else
          lib.nameValuePair "${dir}/SKILL.md" (
            if lib.hm.strings.isPathLike content then { source = content; } else { text = content; }
          );

      explicitFiles = lib.optionalAttrs (lib.isAttrs cfg.skills.explicit) (
        lib.mapAttrs' mkSkillEntry cfg.skills.explicit
      );

      sourceFiles = lib.mapAttrs' (
        _: skill:
        lib.nameValuePair "${dest}/${skill.id}" {
          source = skill.dir;
          recursive = true;
        }
      ) selectedSkills;
    in
    {
      options.programs.agents.skills = {
        enable = lib.mkEnableOption "the shared ~/.agents/skills directory";

        sources = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                path = lib.mkOption {
                  type = lib.types.nullOr lib.types.path;
                  default = null;
                  description = "Path to a skills root (a directory of skills).";
                };
                input = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = "Name of a flake input pointing at a skills root.";
                };
                subdir = lib.mkOption {
                  type = lib.types.str;
                  default = ".";
                  description = "Subdirectory of the source that holds the skills.";
                };
                idPrefix = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = "Prefix prepended to discovered skill ids (must not end with '/').";
                };
                filter.maxDepth = lib.mkOption {
                  type = lib.types.nullOr lib.types.int;
                  default = null;
                  description = "Maximum recursion depth for SKILL.md discovery; null = unlimited.";
                };
                filter.nameRegex = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = "Regex matched against a skill's relative path to restrict discovery.";
                };
              };
            }
          );
          default = { };
          description = ''
            Named sources of agent skills. Each source is either a `path` or a
            flake `input` (plus optional `subdir`), and every directory under
            it containing a {file}`SKILL.md` becomes a skill. A skill at the
            source root takes the source name as its id; nested skills use
            their `/`-separated relative path.
          '';
        };

        skills = {
          enableAll = lib.mkOption {
            type = lib.types.either lib.types.bool (lib.types.listOf lib.types.str);
            default = false;
            description = ''
              Enable all discovered skills. A boolean applies to every source;
              a list restricts it to those source names.
            '';
          };

          enable = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Skill ids to enable, as discovered from {option}`programs.agents.skills.sources`.";
          };

          explicit = lib.mkOption {
            type = lib.types.either (lib.types.attrsOf (
              lib.types.oneOf [
                lib.types.lines
                lib.types.path
                lib.types.str
              ]
            )) lib.types.path;
            default = { };
            description = ''
              Inline skills, written directly to {file}`~/.agents/skills/`.

              Either an attribute set of skills or a path to a directory of
              skill folders:

              - An attribute value that is a string (or a file path) becomes
                the skill's {file}`SKILL.md`; a path to a directory becomes the
                whole skill directory.
              - A path value is expected to contain one folder per skill,
                each containing a {file}`SKILL.md`. The directory is symlinked
                to {file}`~/.agents/skills/`.

              This also accepts Nix store paths, for example a skill directory
              from a package.
            '';
          };
        };

        targets.agents = {
          enable = lib.mkEnableOption "installation to {file}`~/.agents/skills`";
          path = lib.mkOption {
            type = lib.types.str;
            default = ".agents/skills";
            description = "Installation path relative to {file}`$HOME`.";
          };
        };
      };

      config = lib.mkIf cfg.enable {
        home.file = lib.mkIf cfg.targets.agents.enable (
          sourceFiles
          // (lib.optionalAttrs (lib.hm.strings.isPathLike cfg.skills.explicit) {
            ${dest} = {
              source = cfg.skills.explicit;
              recursive = true;
            };
          })
          // explicitFiles
        );

        warnings = lib.optionals (!cfg.targets.agents.enable) [
          "programs.agents.skills.enable is true, but targets.agents.enable is false; skills are not installed anywhere."
        ];

        assertions = [
          {
            assertion =
              !lib.hm.strings.isPathLike cfg.skills.explicit || lib.pathIsDirectory cfg.skills.explicit;
            message = "programs.agents.skills.skills.explicit must be a directory when set to a path";
          }
          {
            assertion =
              !lib.hm.strings.isPathLike cfg.skills.explicit || (cfg.sources == { } && selected == [ ]);
            message = "programs.agents.skills.skills.explicit as a path takes over the whole skills directory; it cannot be combined with sources or skills.enable";
          }
          {
            assertion =
              !cfg.targets.agents.enable
              || cfg.sources != { }
              || cfg.skills.explicit != { }
              || (
                if builtins.isBool cfg.skills.enableAll then cfg.skills.enableAll else cfg.skills.enableAll != [ ]
              )
              || cfg.skills.enable != [ ];
            message = "programs.agents.skills has no skills: set sources, skills.enable/enableAll, or skills.explicit";
          }
        ];
      };
    };
}
