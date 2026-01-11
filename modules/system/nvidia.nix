{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.system.nvidia;
in {
  options.modules.system.nvidia = { enable = mkEnableOption "nvidia support"; };

  config = mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;

      powerManagement.enable = true;
      powerManagement.finegrained = true;

      open = true;

      nvidiaSettings = true;

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        amdgpuBusId = "PCI:0:6:0";
        nvidiaBusId = "PCI:0:1:0";
      };

      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
