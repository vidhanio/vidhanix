{
  flake.aspects =
    { aspects, ... }:
    {
      gui.includes = with aspects; [
        core

        # keep-sorted start
        _1password
        agent-browser
        alacritty
        audio
        bat
        bb
        btop
        clipboard
        comma
        crush
        cursor
        direnv
        eza
        face
        fd
        fonts
        fzf
        gh
        ghostty
        git
        gnome-keyring
        greeter
        helium
        herdr
        hyprland
        kitty
        lazygit
        lock
        logind
        minecraft
        mosh
        nautilus
        nixcord
        nixvim
        noctalia
        omp
        opencode2
        ozone
        pi-coding-agent
        prime-agent
        random-term
        ripgrep
        spicetify
        spotify-player
        steam
        stylix
        tmux
        udisks
        upower
        vacuum-tube
        wallpaper
        wezterm
        xdg-autostart
        yazi
        yt-dlp
        zoxide
        # keep-sorted end
      ];
    };
}
