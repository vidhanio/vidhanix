{ den, ... }:
{
  # Only strict-type the entity kinds we declare custom schema options on;
  # `aspect`/`home`/`flake` keep den's default freeform behavior since we
  # don't add ad hoc attributes there.
  den.schema.host = den.lib.strict;
  den.schema.user = den.lib.strict;
}
