{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Hetzner Cloud exposes this VM through QEMU with virtio-scsi and AHCI.
  # Keep these in the initrd so the root disk exists before filesystem mounts.
  boot.initrd.availableKernelModules = [
    "ahci"
    "sd_mod"
    "sr_mod"
    "virtio_pci"
    "virtio_scsi"
    "xhci_pci"
  ];

  boot.initrd.kernelModules = [ "btrfs" ];
}
