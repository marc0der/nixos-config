{
  description = "Modular NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      fenix,
      ...
    }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      nixpkgsConfig = {
        config = import ./unfree-nixpkgs.nix { inherit lib; };
      };
      pkgs = import nixpkgs {
        inherit system;
        config = nixpkgsConfig.config;
      };
      unstable = import nixpkgs-unstable {
        inherit system;
        config = nixpkgsConfig.config;
      };

      rustToolchain = fenix.packages.${system};

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
          extraSpecialArgs = { inherit unstable rustToolchain; };
          modules = [
            ./home.nix
            ./neomorph/home.nix
            ./git.nix
            ./report.nix
            ./zsh.nix
            ./rust.nix
          ];
        };
        "marco@xenomorph" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit unstable rustToolchain; };
          modules = [
            ./home.nix
            ./xenomorph/home.nix
            ./git.nix
            ./report.nix
            ./zsh.nix
            ./rust.nix
          ];
        };
      };
    };
}
