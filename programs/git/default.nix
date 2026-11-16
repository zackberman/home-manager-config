{ config, ... }:

{
  programs.git = {
    enable = true;

    # With stateVersion 23.11, Home Manager adds explicit GPG settings by
    # default. Leave them unset to preserve Git's defaults and repo-specific
    # signing configuration; this does not disable signing.
    signing.format = null;

    settings = {
      alias = {
        rb2 = "!git commit --fixup HEAD && git rebase -i HEAD~2 --autosquash";
        rb3 = "!git commit -m fixmeup && git rebase -i HEAD~3";
        rbc = "!git rebase --continue";
        red = "!git rebase --edit-todo";
      };
      user = {
        name = "Zack Berman";
        email = "2140721+zackberman@users.noreply.github.com";
      };
      core = {
        editor = "vim";
        pager = "delta";
        preloadindex = true;
        fscache = true;
      };
      diff.colorMoved = "default";
      push.default = "simple";
      pull.rebase = true;
      gc.auto = 256;

      delta = {
        navigate = true;
        light = false;
        side-by-side = true;
      };

      interactive.diffFilter = "delta --color-only";
    };
  };

  xdg.configFile."git/config" = {
    target = "${config.home.homeDirectory}/.gitconfig";
    force = true;
  };
}
