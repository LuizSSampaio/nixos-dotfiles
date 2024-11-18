{
  description = "Nixos flake configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ...}@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
        config.allowUnfree = true;
    };
    lib = nixpkgs.lib;
  in {
  nixosConfigurations = {
    default = lib.nixosSystem rec {
      #inherit system;
      specialArgs = { inherit hyprland; inherit inputs; inherit system; };
      modules = [
        ./hosts/default/configuration.nix
	./modules/nvidia.nix
	./modules/audio.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.luiz = import ./hosts/default/home.nix;
          home-manager.extraSpecialArgs = specialArgs;
	  home-manager.backupFileExtension = "backup";
        }
      ];
    };
  };
};
}
