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

{ config, pkgs, ... }:

{
  systemd.services.reset-broadcom-wl-pci = {
    description = "Find and reset Broadcom WiFi PCI device after resume";
    serviceConfig.Type = "oneshot";

    # Add pciutils to the service's PATH to make `lspci` available at runtime.
    path = [ pkgs.systemd pkgs.pciutils ];

    # This service should run after the system wakes up from suspend.
    after = [ "suspend.target" ];
    wantedBy = [ "suspend.target" ];

    # The script that performs the fix.
    # Note: All shell variables like `${VAR}` must be escaped as `''${VAR}`
    # to prevent the Nix interpreter from evaluating them during build time.
    script = ''
      # The kernel driver name for this hardware.
      WIFI_DRIVER="brcmfmac"

      # Dynamically find the PCI address of the Broadcom wireless card.
      # `lspci` lists devices, `grep` filters for the Broadcom network controller,
      # and `awk` extracts the first field (the PCI address).
      # The ''$(...) syntax ensures this command substitution is performed by the shell, not Nix.
      WIFI_PCI_ID=''$(lspci | grep "Network controller.*Broadcom" | awk '{print $1}')

      # Robustness check: if the PCI ID is not found, log an error and exit gracefully.
      if [ -z "''${WIFI_PCI_ID}" ]; then
        echo "Broadcom WiFi device not found. Aborting."
        exit 1
      fi

      # A short delay to ensure the system is stable after resuming.
      sleep 2

      # 1. Unbind: Forcefully detach the device from its driver.
      #    This simulates physically unplugging the device from the PCI bus.
      echo "Unbinding WiFi device ''${WIFI_PCI_ID} from driver ''${WIFI_DRIVER}"
      echo "''${WIFI_PCI_ID}" > "/sys/bus/pci/drivers/''${WIFI_DRIVER}/unbind"

      sleep 1

      # 2. Bind: Re-attach the device to its driver.
      #    This forces a complete re-initialization of the hardware and driver.
      echo "Binding WiFi device ''${WIFI_PCI_ID} to driver ''${WIFI_DRIVER}"
      echo "''${WIFI_PCI_ID}" > "/sys/bus/pci/drivers/''${WIFI_DRIVER}/bind"

      sleep 2

      # 3. Restart NetworkManager: Ensure it detects the re-initialized device
      #    and properly manages network connections.
      # The SYSTEMCTL variable is defined for clarity, pointing to the absolute path.
      SYSTEMCTL="/run/current-system/sw/bin/systemctl"
      ''${SYSTEMCTL} restart NetworkManager
    '';
  };
}
