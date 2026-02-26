{
  description = "Test configuration for Home Manager mutable files";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Point to fork/branch with the mutable patch
    home-manager.url = "github:no-mood/home-manager/mutable-files";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }:
    {
      # Standalone home-manager configuration (recommended for testing)
      homeConfigurations = {
        "test" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./home.nix ];
        };
      };

      # NixOS configuration (optional)
      nixosConfigurations = {
        testhost = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.test = import ./home.nix;
            }
          ];
        };
      };
    };
}
