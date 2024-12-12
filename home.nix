{ config, pkgs, ... }:

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
}
