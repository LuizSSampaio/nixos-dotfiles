# Declarative description of this machine's EXISTING disk layout.
#
# !!! SAFETY !!!
# This file is used DECLARATIVELY ONLY: imported as a NixOS module, it just
# generates fileSystems / boot.initrd.luks.devices / swapDevices config.
#
# NEVER run the disko CLI against this repository (no `disko`, `disko-install`,
# or `nix run github:nix-community/disko`). The default CLI mode is
# destroy+format+mount. As defense in depth, both disks below set
# `destroy = false` (disko's destroy stage skips them entirely) and every
# partition is pinned to its existing PARTUUID with its existing type code
# and exact sector boundaries, so even a stray CLI run cannot wipe or
# reformat them.
#
# Any intentional repartitioning requires deleting this warning header first.
{ ... }:
{
  disko.devices = {
    # Volatile root: everything on / is lost on reboot; persistent state is
    # bind-mounted back from the ext4 at /nix by preservation
    # (hosts/legion/persistence.nix). Previous generations mount the ext4
    # at "/" instead — booting one from the Limine menu is the rollback.
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "defaults"
        "mode=0755"
        "size=8G"
      ];
    };

    disk.boot = {
      device = "/dev/disk/by-id/nvme-SKHynix_HFS001TEJ9X115N_AMCAN00441280AO4D";
      type = "disk";
      destroy = false;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            # exact existing boundaries (only relevant to the forbidden CLI path)
            start = "4096s";
            end = "2101247s";
            type = "EF00";
            uuid = "56adedd0-e7e9-42b7-9713-568f2ca25503";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "fmask=0077" "dmask=0077" ];
            };
          };
          cryptroot = {
            start = "2101248s";
            end = "1966231387s";
            type = "8300";
            uuid = "f434196d-7c35-4e58-bf6d-be26ab35235d";
            content = {
              type = "luks";
              name = "cryptroot";
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
              };
              content = {
                type = "filesystem";
                format = "ext4";
                # Persistent store (the ext4's fs root is mounted at /nix):
                # holds /nix/store and, at its on-disk root, the preserved
                # /etc, /home, /var, /root trees that preservation
                # bind-mounts back into place. Zero data movement: the
                # on-disk /etc, /home, /var, /root keep their pre-migration
                # physical locations.
                mountpoint = "/nix";
                mountOptions = [ "defaults" ];
              };
            };
          };
          cryptswap = {
            start = "1966231388s";
            end = "2000409197s";
            type = "8300";
            uuid = "762c51eb-0388-4996-af02-229d906877d0";
            content = {
              type = "luks";
              name = "cryptswap";
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
              };
              content = { type = "swap"; };
            };
          };
        };
      };
    };

    disk.storage = {
      device = "/dev/disk/by-id/nvme-GIGABYTE_GP-GSM2NE3256GNTD_SN211408907453";
      type = "disk";
      destroy = false;
      content = {
        type = "luks";
        name = "cryptstorage";
        settings = {
          allowDiscards = true;
          bypassWorkqueues = true;
        };
        content = {
          type = "lvm_pv";
          vg = "vg-storage";
        };
      };
    };

    lvm_vg."vg-storage" = {
      type = "lvm_vg";
      lvs.storage = {
        size = "100%FREE";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/mnt/storage";
          mountOptions = [
            "defaults"
            "nofail"
          ];
        };
      };
    };
  };
}
