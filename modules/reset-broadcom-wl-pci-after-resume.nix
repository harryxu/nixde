# This NixOS module provides an automatic fix for a common WiFi issue
# on certain Apple MacBooks running NixOS.
#
# PROBLEM:
#   The WiFi card, which uses the Broadcom `brcmfmac` driver, fails to
#   reconnect or scan for networks after the system resumes from suspend
#   (sleep). A full reboot is typically required to restore functionality.
#
# APPLICABLE TO:
#   - Apple MacBooks (and potentially other machines) with Broadcom wireless
#     adapters (e.g., BCM43602).
#   - Systems where the `brcmfmac` kernel module is the active driver for
#     the wireless card.
#
# USAGE:
#   1. Ensure `pciutils` is available for diagnostics.
#      environment.systemPackages = with pkgs; [
#        pciutils
#        # ... other packages
#      ];
#
#   2. Import this file into `configuration.nix` by adding it to the `imports` list.
#
#      # configuration.nix
#      { ... }: {
#        imports = [
#          ./hardware-configuration.nix
#          ./modules/reset-broadcom-wl-pci-after-resume.nix  # <-- Add this line
#        ];
#
#        # ... other system configurations
#      }
#
# =============================================================================

# /path/to/your/modules/reset-broadcom-wl-pci-after-resume.nix

{ config, pkgs, ... }:

let
  wifiResumeScript = pkgs.writeShellScriptBin "wifi-resume-script" ''
    #!${pkgs.runtimeShell}

    LOG_TAG="WiFi-Resume-Fix"
    LOGGER="${pkgs.util-linux}/bin/logger -t $LOG_TAG"

    $LOGGER "--- Resume script starting execution after delay ---"

    LSPCI=${pkgs.pciutils}/bin/lspci
    GREP=${pkgs.gnugrep}/bin/grep
    AWK=${pkgs.gawk}/bin/awk
    SYSTEMCTL=${pkgs.systemd}/bin/systemctl

    WIFI_DRIVER="brcmfmac"

    $LOGGER "Finding PCI ID..."
    WIFI_PCI_ID=$($LSPCI -D | $GREP "Network controller.*Broadcom" | $AWK '{print $1}')

    if [ -z "''${WIFI_PCI_ID}" ]; then
      $LOGGER "FATAL: Could not find Broadcom WiFi PCI ID. Aborting."
      exit 1
    fi

    $LOGGER "Found device at ''${WIFI_PCI_ID}. Proceeding with reset."

    $LOGGER "Step 1/3: Unbinding device..."
    echo "''${WIFI_PCI_ID}" > "/sys/bus/pci/drivers/''${WIFI_DRIVER}/unbind" || $LOGGER "ERROR: Failed to unbind."

    sleep 1

    $LOGGER "Step 2/3: Binding device..."
    echo "''${WIFI_PCI_ID}" > "/sys/bus/pci/drivers/''${WIFI_DRIVER}/bind" || $LOGGER "ERROR: Failed to bind."

    sleep 2

    $LOGGER "Step 3/3: Restarting NetworkManager..."
    $SYSTEMCTL restart NetworkManager || $LOGGER "ERROR: Failed to restart NetworkManager."

    $LOGGER "--- Script finished. ---"
  '';

in

{
  systemd.services."wifi-resume-fix" = {
    description = "Definitive fix for Broadcom WiFi on resume (Correct Module Syntax)";

    wantedBy = [ "sleep.target" ];
    after = [ "sleep.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${wifiResumeScript}/bin/wifi-resume-script";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 7";
    };
  };
}
