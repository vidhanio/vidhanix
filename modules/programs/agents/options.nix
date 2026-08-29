{
  flake.aspects.agents = {
    homeManager =
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
          models = lib.mkOption {
            type = lib.types.submodule {
              options = {
                large = lib.mkOption {
                  type = modelType;
                  description = "Model used for complex tasks.";
                };

                small = lib.mkOption {
                  type = modelType;
                  description = "Model used for simple tasks.";
                };
              };
            };
            description = "Models shared by the agents.";
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

          skills = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.oneOf [
                lib.types.lines
                lib.types.path
                lib.types.str
              ]
            );
            default = { };
            example = lib.literalExpression ''
              {
                pdf-processing = '''
                  ---
                  name: pdf-processing
                  description: Extract text and tables from PDF files, fill forms, merge documents.
                  ---

                  # PDF Processing

                  Use pdfplumber to extract text from PDFs.
                ''';
                xlsx = ./skills/xlsx/SKILL.md;
                data-analysis = ./skills/data-analysis;
              }
            '';
            description = ''
              Custom skills for the agents.

              The attribute name becomes the skill directory name, and the
              value is either:
              - Inline content as a string (creates {file}`~/.agents/skills/<name>/SKILL.md`)
              - A path to a file (creates {file}`~/.agents/skills/<name>/SKILL.md`)
              - A path to a directory (creates {file}`~/.agents/skills/<name>/` with all files)

              This also accepts Nix store paths, for example a skill directory
              from a package.

              A directory that holds a whole collection of skills, such as a
              skills repository, is symlinked under the attribute name as well;
              each skill folder inside it stays reachable at
              {file}`~/.agents/skills/<name>/<skill>/SKILL.md`.
            '';
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

            skillsDir = "${config.home.homeDirectory}/.agents/skills";

            mkSkillEntry =
              name: content:
              if lib.isPath content && lib.pathIsDirectory content then
                lib.nameValuePair "${skillsDir}/${name}" {
                  source = content;
                  recursive = true;
                }
              else if lib.isPath content then
                lib.nameValuePair "${skillsDir}/${name}/SKILL.md" { source = content; }
              else if lib.hm.strings.isPathLike content then
                lib.nameValuePair "${skillsDir}/${name}" {
                  source = normalizeSkill name content;
                  recursive = true;
                }
              else
                lib.nameValuePair "${skillsDir}/${name}/SKILL.md" { text = content; };
          in
          {
            home.file = {
              "AGENTS.md" =
                if lib.isPath cfg.context then
                  { source = cfg.context; }
                else
                  lib.mkIf (cfg.context != "") {
                    text = cfg.context;
                  };
            }
            // lib.mapAttrs' mkSkillEntry cfg.skills;
          };
      };
  };
}
