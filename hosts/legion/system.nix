{ lib, ... }:
{
  imports = [ ../../modules/system/default.nix ];

  boot = {
    loader = {
      limine = {
        enable = true;
        efiSupport = true;
        enableEditor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    initrd = {
      availableKernelModules = [ "dm_mod" ];

      luks.devices = lib.mkForce {
        cryptroot = {
          device = "/dev/disk/by-uuid/82c28330-9254-4b1c-908a-4ddf127a53d0";
          allowDiscards = true;
          bypassWorkqueues = true;
        };

        cryptswap = {
          device = "/dev/disk/by-uuid/ae661835-887b-44ea-b85a-c3fccf50438c";
          allowDiscards = true;
          bypassWorkqueues = true;
        };

        cryptstorage = {
          device = "/dev/disk/by-uuid/b6abffa9-06b2-47e4-8a01-2b73dca6da81";
          allowDiscards = true;
          bypassWorkqueues = true;
        };
      };
    };
  };

  fileSystems."/" = lib.mkForce {
    device = "/dev/mapper/cryptroot";
    fsType = "ext4";
  };

  fileSystems."/mnt/storage" = {
    device = "/dev/mapper/vg--storage-storage";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
    ];
  };

  swapDevices = lib.mkForce [
    { device = "/dev/mapper/cryptswap"; }
  ];

  networking.networkmanager.ensureProfiles.profiles = {
    br0 = {
      connection = {
        id = "br0";
        type = "bridge";
        interface-name = "br0";
        autoconnect = true;
      };
      bridge = {
        stp = false;
      };
      ipv4.method = "auto";
      ipv6.method = "auto";
    };

    "br0-enp8s0f3u1u1" = {
      connection = {
        id = "br0-enp8s0f3u1u1";
        type = "ethernet";
        interface-name = "enp8s0f3u1u1";
        master = "br0";
        slave-type = "bridge";
        autoconnect = true;
      };
    };
  };

  modules.system = {
    nvidia.enable = true;
    greetd = {
      enable = true;
      session = "niri";
    };
    steam.enable = true;
    plymouth.enable = true;
    polkit-kde.enable = true;
  };
}
