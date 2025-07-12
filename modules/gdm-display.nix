# /etc/nixos/gdm-display.nix
#
# This NixOS module configures GDM (GNOME Display Manager)
# to use a predefined display layout on startup.
# This is typically used to force the login screen to appear on an external monitor.
# Usage: Import this file from configuration.nix

{ config, pkgs, ... }:

let
  env = import ../env.nix;

  # Read the content of the monitors.xml file located in the user config directory as this file.
  # This file defines your preferred display settings (e.g., setting the external monitor as primary).
  # You must first set up your displays in the GNOME desktop environment,
  monitorsXmlContent = builtins.readFile "/home/${env.username}/.config/monitors.xml";

  # Write the XML content to a file in the Nix Store, giving it a stable, referencable path.
  monitorsConfig = pkgs.writeText "gdm_monitors.xml" monitorsXmlContent;
in
{
  # Use the systemd-tmpfiles service to create a symbolic link.
  # GDM looks for a monitors.xml file in the /run/gdm/.config/ directory on startup.
  # This rule ensures the link is ready before GDM starts. [1, 3]
  systemd.tmpfiles.rules = [
    # L+ creates a symbolic link, overwriting the target if it already exists.
    # The link source is our config file in the Nix Store, and the target is GDM's configuration path.
    "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}"
  ];
}
