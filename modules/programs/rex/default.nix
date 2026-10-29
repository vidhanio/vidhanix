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
