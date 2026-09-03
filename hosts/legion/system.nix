{ lib, ... }:
{
  imports = [
    ../../modules/system/default.nix
    ./disko.nix
    ./persistence.nix
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

  # Canary guard for the impermanence migration: no unattended reboots until
  # the preservation list has been validated in daily use. Remove after the
  # canary period (see AGENTS.md, "Impermanence").
  system.autoUpgrade.allowReboot = lib.mkForce false;

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
