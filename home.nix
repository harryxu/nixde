{ config, pkgs, lib, ... }:

{
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    vscode zed-editor google-chrome
    blueman

    # hyprland packages
    hyprland hypridle hyprlock xdg-desktop-portal-hyprland
    waybar wofi pavucontrol grim slurp swaybg waypaper
    swaynotificationcenter
  ];

  # Cursor theme
  home.pointerCursor = {
    name = "Adwaita";
    size = 24;
    package = pkgs.adwaita-icon-theme;
    x11.enable = true;
    gtk.enable = true;
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
