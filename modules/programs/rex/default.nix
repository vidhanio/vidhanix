{ inputs, ... }:
let
  wrapRex =
    pkgs: rex:
    pkgs.symlinkJoin {
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
        pkgs.writableTmpDirAsHomeHook
      ];
      postBuild = ''
        $out/bin/rex skill setup --agent pi
        installSkill "$HOME/.agents/skills/rex"

        installShellCompletion --cmd rex \
          --bash <($out/bin/rex completion bash) \
          --zsh <($out/bin/rex completion zsh) \
          --fish <($out/bin/rex completion fish)

        install -d $out/share/nushell/vendor/autoload
        {
          echo 'let __rex_previous_external = ($env.config.completions.external? | default {})'
          echo 'let __rex_previous_completer = ($__rex_previous_external.completer? | default null)'
          $out/bin/rex completion nu
          cat ${pkgs.writeText "rex-nushell-chain.nu" ''
            let __rex_completer = $env.config.completions.external.completer
            let __rex_chain = {|place|
                let result = (do $__rex_completer $place)
                if $result == null and $__rex_previous_completer != null {
                    do $__rex_previous_completer $place
                } else {
                    $result
                }
            }
            $env.config.completions.external = $__rex_previous_external
            $env.config.completions.external.completer = $__rex_chain
          ''}
        } > $out/share/nushell/vendor/autoload/rex.nu
      '';
    };
in
{
  profiles.base = {
    module =
      {
        config,
        pkgs,
        inputs',
        ...
      }:
      let
        tailscaleLogin = "tailscale:vidhanio@github";
      in
      {
        imports = [ inputs.rex.nixosModules.default ];

        services.rex = {
          package = wrapRex pkgs inputs'.rex.packages.rex;
          loginServer = {
            enable = true;
            accounts.${config.users.primaryUser}.principals = [ tailscaleLogin ];
            defaults.${tailscaleLogin} = config.users.primaryUser;
            tailscaleServe.enable = true;
          };
        };
      };

    homeModule =
      { osConfig, ... }:
      {
        agents.skills.packages = [ osConfig.services.rex.package ];
        persist.directories = [ ".local/state/rex" ];
      };
  };
}
