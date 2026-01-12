{ config, lib, pkgs, inputs, ... }:

{
  imports = [ ../../modules/system/default.nix ];

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
      device = "/dev/disk/by-uuid/1d8fc969-553f-4b90-ae84-95c4621ab338";
      allowDiscards = true;
      bypassWorkqueues = true;
    };
  };

  modules.system = {
    nvidia.enable = true;
    greetd.enable = true;
    steam.enable = true;
    plymouth.enable = true;
  };
}
