{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.nvidia;
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in {
  options.modules.system.nvidia = { enable = mkEnableOption "nvidia support"; };

  config = mkIf cfg.enable {
    hardware.graphics.enable = true;

    services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
    environment.systemPackages = [ nvidia-offload ];

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
