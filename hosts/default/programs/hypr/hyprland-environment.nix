{ config, pkgs, ... }:
{
  home = {
    sessionVariables = {
      LIBVA_DRIVER_NAME= "nvidia";
      __GLX_VENDOR_LIBRARY_NAME= "nvidia";
    };
  };
}
