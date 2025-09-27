{
  lib,
  osConfig,
  ...
}:
lib.mkIf osConfig.services.sunshine.enable or false {
  impermanence.directories = [ ".config/sunshine" ];
}
