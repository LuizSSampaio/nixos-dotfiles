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
      device = "/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
      allowDiscards = true;
      bypassWorkqueues = true;
    };

    cryptstorage = {
      device = "/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
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
