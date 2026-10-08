{
  profiles.pc.homeModule = {
    programs.noctalia.settings.notification = {
      filter_order = [ "no_sound" ];
      filter.no_sound = {
        enabled = true;
        match_content = ".*";
        play_sound = false;
      };
    };
  };
}
