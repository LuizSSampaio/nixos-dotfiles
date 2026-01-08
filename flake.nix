{
  description = "A NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, niri-flake, ... } @ inputs:
    let
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      lib = nixpkgs.lib;

      mkSystem = pkgs: system: hostname:
        pkgs.lib.nixosSystem {
          system = system;
          modules = [
            { networking.hostName = hostname; }
            ./modules/system/configuration.nix
            (./. + "/hosts/${hostname}/hardware-configuration.nix")
            { nixpkgs.overlays = [ niri-flake.overlays.niri ]; }
            niri-flake.nixosModules.niri
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                extraSpecialArgs = { inherit inputs; };
                users.luiz = (./. + "/hosts/${hostname}/user.nix");
                # Only use homeModules.config for settings validation
                # nixosModules.niri already handles package installation
                sharedModules = [
                  niri-flake.homeModules.config
                ];
              };
            }
          ];
          specialArgs = { inherit inputs; };
        };
    in {
      nixosConfigurations = {
        vm = mkSystem inputs.nixpkgs "x86_64-linux" "vm";
        laptop = mkSystem inputs.nixpkgs "x86_64-linux" "laptop";
      };
    };
}
