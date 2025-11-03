{
  lib,
  osConfig,
  ...
}:
lib.mkIf osConfig.services.sunshine.enable or false {
  persist.directories = [ ".config/sunshine" ];
}
