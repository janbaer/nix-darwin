{
  description = "Jan's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nix-homebrew, ... }:
  let
    username = "jan.baer";
    system = "aarch64-darwin";

    # nodeOverlay = final: prev: {
    #   nodejs = prev.nodejs_22;
    #   nodejs-slim = prev.nodejs-slim_22;
    #
    #   nodejs_20 = prev.nodejs_22;
    #   nodejs-slim_20 = prev.nodejs-slim_22;
    # };

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        allowUnsupportedSystem = true;
        allowBroken = true;
      };
      # overlays = [ nodeOverlay ];
    };

  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#M9WMQ6QPM7
    darwinConfigurations."M9WMQ6QPM7" = nix-darwin.lib.darwinSystem {
      inherit system;

      specialArgs = {
        inherit self;
        inherit pkgs;
        inherit username;
        inherit system;
      };

      modules = [
        ./hosts/macbook-work/configuration.nix

        home-manager.darwinModules.home-manager
        {
          # `home-manager` config
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${username}" = import ./home.nix;
          home-manager.extraSpecialArgs = {
            inherit pkgs;
            # inherit pkgs-unstable;
          };
        }

        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = username;
            autoMigrate = true;
          };
        }
      ];
    };
  };
}
