{ inputs, ... }:
{
  profiles.base = {
    module =
      { config, ... }:
      {
        users.users.${config.users.primaryUser}.linger = true;
      };

    homeModule =
      {
        config,
        osConfig,
        pkgs,
        inputs',
        ...
      }:
      let
        rex = inputs'.rex.packages.rex;
        package = pkgs.symlinkJoin {
          inherit (rex)
            name
            pname
            version
            meta
            ;
          paths = [ rex ];
          nativeBuildInputs = [
            pkgs.installAgentSkills
            pkgs.installShellFiles
          ];
          postBuild = ''
            export HOME="$TMPDIR/rex-home"
            mkdir -p "$HOME"
            $out/bin/rex skill setup --agent pi
            installSkill "$HOME/.agents/skills/rex"

            installShellCompletion --cmd rex \
              --bash <($out/bin/rex completion bash) \
              --zsh <($out/bin/rex completion zsh) \
              --fish <($out/bin/rex completion fish) \
              --nushell <($out/bin/rex completion nu)
          '';
        };
      in
      {
        imports = [ inputs.rex.homeManagerModules.default ];

        programs.ssh.enable = true;
        programs.rex = {
          enable = true;
          inherit package;
        };
        agents.skills.packages = [ config.programs.rex.package ];
        services.rex = {
          enable = true;
          tailscale = {
            enable = true;
            hostname = "rex-${osConfig.networking.hostName}";
          };
        };

        persist.directories = [ ".local/state/rex" ];
      };
  };
}
