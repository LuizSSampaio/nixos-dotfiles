{...}: {
  imports = [../../modules/system/default.nix];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
      editor = false;
      consoleMode = "auto";
    };
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  boot.initrd.luks.devices = {
    cryptroot = {
      device = "/dev/disk/by-uuid/82c28330-9254-4b1c-908a-4ddf127a53d0";
      allowDiscards = true;
      bypassWorkqueues = true;
    };

    cryptstorage = {
      device = "/dev/disk/by-uuid/b6abffa9-06b2-47e4-8a01-2b73dca6da81";
      allowDiscards = true;
      bypassWorkqueues = true;
    };
  };

  fileSystems."/mnt/storage" = {
    device = "/dev/mapper/vg--storage-storage";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
    ];
  };

  modules.system = {
    nvidia.enable = true;
    greetd = {
      enable = true;
      session = "niri";
    };
    steam.enable = true;
    plymouth.enable = true;
  };
}
