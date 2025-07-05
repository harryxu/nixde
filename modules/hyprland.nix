{ pkgs, ...}: {
  programs.hyprland = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    waybar
    wofi
    dunst
    pavucontrol
    grim slurp
    xdg-desktop-portal-hyprland
  ];

}
