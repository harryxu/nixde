{
  description = "NixOS DE for developer.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ghostty }:
    let
      env = import ./env.nix;
    in {
      nixosConfigurations.nixde = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix

          ({ pkgs, ... }: {
            environment.systemPackages = [
              ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
            ];
          })

          ./nixde-system.nix

          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${env.username} = import ./home.nix;
            };
          }
        ];
      };
    };
}
