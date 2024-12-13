{ config, pkgs, lib, ... }:

{
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

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
