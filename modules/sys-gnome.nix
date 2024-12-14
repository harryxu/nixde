{config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    gnome-session
    gnome-terminal
    gnome-tweaks
    gnomeExtensions.dash-to-dock
  ];

  # Enable RDP.
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
  services.xrdp.openFirewall = true;

}
