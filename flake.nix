{
  description = "Modular NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    inputs@{ self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , ...
    }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";

      # Define common configuration for both channels
      nixConfig = { allowUnfree = true; };

      pkgs = import nixpkgs {
        inherit system;
        config = nixConfig;
      };

      unstable = import nixpkgs-unstable {
        inherit system;
        config = nixConfig;
      };
    in
    {
      nixosConfigurations = {
        xenomorph = lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            ./xenomorph/configuration.nix
            ./xenomorph/hardware-configuration.nix
          ];
        };
        neomorph = lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            ./neomorph/configuration.nix
            ./neomorph/hardware-configuration.nix
          ];
        };
      };
      homeConfigurations = {
        "marco@neomorph" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit unstable; };
          modules = [
            ./home.nix
            ./neomorph/home.nix
            ./git.nix
            ./report.nix
            ./zsh.nix
          ];
        };
        "marco@xenomorph" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit unstable; };
          modules = [
            ./home.nix
            ./xenomorph/home.nix
            ./git.nix
            ./report.nix
            ./zsh.nix
          ];
        };
      };
    };
}
