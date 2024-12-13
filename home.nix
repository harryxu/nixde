{ config, pkgs, lib, ... }:

{
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/Fish#Setting_fish_as_your_shell
  # programs.bash = {
  #   interactiveShellInit = ''
  #     if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
  #     then
  #       shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
  #       exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
  #     fi
  #   '';
  # };

  programs.git = {
    enable = true;
    aliases = {
      ci = "commit";
      co = "checkout";
      st = "status";
    };
  extraConfig = {
      init = {
        defaultBranch = "main";
      };
      core = {
        editor = "nvim";
      };
    };
  };

  # Setup dotfiles.
  home.activation.setupDotfiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d ~/.config/.git ]; then
      mkdir -p ~/.config
      cd ~/.config
      ${pkgs.git}/bin/git init
      ${pkgs.git}/bin/git remote add origin https://github.com/harryxu/dotconfig.git
      ${pkgs.git}/bin/git fetch
      ${pkgs.git}/bin/git checkout origin/main -ft
      ${pkgs.git}/bin/git submodule init
      ${pkgs.git}/bin/git submodule update
    fi
  '';

}
