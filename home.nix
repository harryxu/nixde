{ config, pkgs, lib, ... }:

{
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    vscode
    zed-editor
    google-chrome

    # hyprland packages
    hyprland
    waybar
    wofi
    dunst
    pavucontrol
    grim slurp
    xdg-desktop-portal-hyprland
  ];

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
