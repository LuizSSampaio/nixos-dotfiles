{
  description = "A NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, niri, ... } @ inputs:
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
	        { nixpkgs.overlays = [ niri.overlays.niri ]; }
	        home-manager.nixosModules.home-manager {
	          home-manager = {
	          useUserPackages = true;
		        useGlobalPkgs = true;
		        extraSpecialArgs = { inherit inputs; };
		        users.luiz = (./. + "/hosts/${hostname}/user.nix");
		        sharedModules = [
		          niri.homeModules.niri
		          niri.homeModules.config
		          niri.homeModules.stylix
		        ];
	          };
	        }
	      ];
        specialArgs = { inherit inputs; };
	    };
    in {
      nixosConfigurations =  {
        vm = mkSystem inputs.nixpkgs "x86_64-linux" "vm";
        laptop = mkSystem inputs.nixpkgs "x86_64-linux" "laptop";
      };
    };
}
