{ config, lib, inputs, ... }:

{
  imports = [ ../../modules/system/default.nix ];

  # Host-specific bootloader configuration (VM uses GRUB on /dev/vda)
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
    useOSProber = true;
  };

  config.modules.system = {
    greetd.enable = true;
    steam.enable = true;
    plymouth.enable = true;
  };
}
