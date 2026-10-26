{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.agents;

  modelType = lib.types.submodule {
    options = {
      provider = lib.mkOption {
        type = lib.types.str;
        description = "Provider used for the model.";
      };

      model = lib.mkOption {
        type = lib.types.str;
        description = "Model identifier.";
      };

      thinking = lib.mkOption {
        type = lib.types.str;
        description = "Thinking level passed to the agent.";
      };
    };
  };
in
{
  options.programs.agents = {
    models = {
      presets = {
        default = lib.mkOption {
          type = modelType;
          description = "Model used by default.";
        };

        small = lib.mkOption {
          type = modelType;
          description = "Model used for simple tasks.";
        };

        large = lib.mkOption {
          type = modelType;
          description = "Model used for complex tasks.";
        };
      };

      override = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.attrsOf (
            lib.types.submodule {
              options.context = lib.mkOption {
                type = lib.types.ints.positive;
                description = "Context window size in tokens.";
                example = 200000;
              };
            }
          )
        );
        default = { };
        example = lib.literalExpression ''
          {
            opencode-go.deepseek-v4.1-flash.context = 200000;
          }
        '';
        description = ''
          Per-model context window overrides, keyed by provider and then
          model id, applied to every agent's model configuration.
        '';
      };
    };

    context = lib.mkOption {
      type = lib.types.either lib.types.lines lib.types.path;
      description = ''
        Global context for the agents.

        The value is either:
        - Inline content as a string
        - A path to a file containing the content

        The configured content is written to {file}`~/AGENTS.md`.
      '';
      default = "";
      example = lib.literalExpression ''
        '''
          - Prefer the project-local AGENTS.md; escalate to the user before editing system files.
        '''
      '';
    };

    skills = {
      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        example = lib.literalExpression "[ config.programs.herdr.package ]";
        description = ''
          Packages providing skill directories under
          {file}`share/skills/<pname>/`, following the nixpkgs
          `installAgentSkills` convention.
        '';
      };

      bundles = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [ ];
        example = lib.literalExpression ''[ "''${inputs.beautiful-rust}/skills" ]'';
        description = ''
          Directories containing named skill directories, each with a
          {file}`SKILL.md`. Their contents are merged directly into
          {file}`~/.agents/skills/`, without a bundle-name directory.
        '';
      };

      skills = lib.mkOption {
        type = lib.types.attrsOf lib.types.path;
        default = { };
        example = lib.literalExpression ''
          {
            comma = ./COMMA.md;
            meowland = ./meowland;
          }
        '';
        description = ''
          Named skills, each either a directory containing {file}`SKILL.md`
          and supporting files, or a file installed as
          {file}`~/.agents/skills/<name>/SKILL.md`.
          Nix store paths are also supported.
        '';
      };
    };
  };

  config =
    let
      normalizeSkill =
        name: source:
        pkgs.runCommandLocal "agent-skill-${lib.strings.sanitizeDerivationName name}" { } ''
          source=${lib.escapeShellArg "${source}"}
          if [[ -d "$source" ]]; then
            ln -s "$source" "$out"
          elif [[ -f "$source" ]]; then
            mkdir "$out"
            ln -s "$source" "$out/SKILL.md"
          else
            echo "skill source must be a file or directory: $source" >&2
            exit 1
          fi
        '';

      skillDirs = lib.mapAttrsToList (name: source: {
        inherit name;
        path = normalizeSkill name source;
      }) cfg.skills.skills;
    in
    {
      programs.agents.skills.bundles =
        map (package: "${package}/share/skills/${package.pname}") cfg.skills.packages
        ++ [
          (pkgs.linkFarm "agent-skills" skillDirs)
        ];

      home.file = {
        "AGENTS.md" =
          if lib.isPath cfg.context then
            { source = cfg.context; }
          else
            lib.mkIf (cfg.context != "") {
              text = cfg.context;
            };

        ".agents/skills".source = pkgs.symlinkJoin {
          name = "agent-skills-merged";
          paths = cfg.skills.bundles;
        };
      };
    };
}
