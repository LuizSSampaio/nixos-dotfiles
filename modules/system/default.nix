{ config, pkgs, ... }:

{
  imports = [
    ./configuration.nix
    ./greetd.nix
  ];
}
