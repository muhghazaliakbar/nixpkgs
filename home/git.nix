{ config, pkgs, ... }:

let
  me = {
    name = "Muh Ghazali Akbar";
    email = "muhghazaliakbar@live.com";
  };
  PalauaAndSons = {
    name = "Muh Ghazali Akbar";
    email = "muhghazaliakbar@live.com";
  };
  Riviera4Media = {
    name = "Muh Ghazali Akbar";
    email = "muhghazaliakbar@live.com";
  };
in
{
  programs.git.enable = true;

  programs.git.aliases = {
    a = "add";
    c = "clone";
    cfd = "clean -fd";
    ca = "commit --amend";
    can = "commit --amend --no-edit";
    r = "rebase";
    ro = "rebase origin/master";
    rc = "rebase --continue";
    ra = "rebase --abort";
    ri = "rebase -i";
    # need to install vim-conflicted
    res = "!nvim +Conflicted";
    # use for resolve conflicted
    # accept-ours
    aco = "!f() { git checkout --ours -- \"\${@:-.}\"; git add -u \"\${@:-.}\"; }; f";
    # accept-theirs
    ace = "!f() { git checkout --theirs -- \"\${@:-.}\"; git add -u \"\${@:-.}\"; }; f";
    f = "fetch";
    fa = "fetch --all";
  };

  programs.git.extraConfig = {
    rerere.enable = true;
    difftool.prompt = false;
  };

  programs.git.includes = [
    {
      condition = "gitdir:~/Projects/PalauaAndSons/";
      contents.user = PalauaAndSons;
    }

    {
      condition = "gitdir:~/Projects/riviera4media/";
      contents.user = Riviera4Media;
    }

    {
      condition = "gitdir:~/.config/nixpkgs/";
      contents.user = me;
    }
  ];


  ### git tools
  ## github cli
  programs.gh.enable = true;
  programs.gh.settings.git_protocol = "ssh";
  programs.gh.settings.aliases = {
    co = "pr checkout";
    pv = "pr view";
  };
}
