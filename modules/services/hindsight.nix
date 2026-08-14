_: {
  # Local PostgreSQL backing the hindsight user service
  # (programs.ai.hindsight) on this host.
  configurations.vidhan-pc.module =
    { pkgs, ... }:
    {
      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_16.withPackages (ps: [ ps.pgvector ]);
        ensureDatabases = [
          "hindsight"
          "vidhanio"
        ];
        ensureUsers = [
          {
            name = "vidhanio";
            ensureDBOwnership = true;
          }
        ];
      };
    };
}
