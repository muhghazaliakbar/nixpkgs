{ config, pkgs, lib, ... }:

{
  # Packages with configuration --------------------------------------------------------------- {{{

  # Bat, a substitute for cat.
  # https://github.com/sharkdp/bat
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.bat.enable
  programs.bat.enable = true;
  programs.bat.config = {
    style = "plain";
    theme = "TwoDark";
  };
  # Direnv, load and unload environment variables depending on the current directory.

  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Htop
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;

  home.packages = with pkgs;
    [
      ################################## 
      # common
      ################################## 
      coreutils
      curl
      wget
      tree

      ################################## 
      # Platform specific
      ################################## 
      # nodePackages.svg-term-cli
      # nodePackages."@napi-rs/cli"
      # nodePackages.mrm

      ################################## 
      # Manager
      ################################## 
      

      ################################## 
      # Productivity
      ################################## 
      fzf # finder
      fzy
      neofetch # fancy fetch information
      du-dust # fancy du
      fd # fancy find
      jq # JSON in shell
      ripgrep # another yet of grep
      imagemagick

      ################################## 
      # Development
      ################################## 
      ctags
      # yarn # currently defined in devShell.nix
      # google-cloud-sdk
      nodejs-14_x
      yarn
      nodePackages.pnpm
      python3
      pkg-config
      redis
      mailhog
      mysql80
      virtualenv
      python.pkgs.pip
      
      # PHP
      php81
      php81Packages.composer

      ################################## 
      # Shell Integrations
      ################################## 
      starship # theme for shell (bash,fish,zsh)

      ################################## 
      # Misc
      ################################## 

      ################################## 
      # Communication
      ################################## 
      discord-ptb
      slack
      mattermost
      
      ################################## 
      # Useful Nix related tools
      ################################## 
      comma # run without install
      nodePackages.node2nix
      home-manager
      nix-prefetch-git
    ] ++ lib.optionals
      stdenv.isDarwin
      [
        mas
      ];
}
