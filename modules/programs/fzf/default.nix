{
  flake.aspects.fzf.homeManager =
    let
      fd = type: "fd --type ${type} --strip-cwd-prefix --hidden --follow --exclude .git";
    in
    {
      programs.fzf = {
        enable = true;
        defaultCommand = fd "f";
        fileWidget.command = fd "f";
        changeDirWidget.command = fd "d";
      };
    };
}
