{ lib, ... }:
{
  imports = [
    ../../modules/system/default.nix
    ./disko.nix
  ];

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
    initrd.availableKernelModules = [ "dm_mod" ];
  };

  modules.system = {
    batteryThreshold.enable = true;
    fingerprint.enable = true;
    nvidia.enable = true;
    greetd = {
      enable = true;
      session = "niri";
    };
    steam.enable = true;
    plymouth.enable = true;
    polkit-kde.enable = false;
    sops.enable = true;
  };
}
