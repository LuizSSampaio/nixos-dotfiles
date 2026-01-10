{ config, pkgs, ... }:

{
  imports = [
    ./configuration.nix
    ./fonts.nix
    ./greetd.nix
  ];
}
