{
  description = "Modular NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    claude-desktop.url = "github:k3d3/claude-desktop-linux-flake";
    claude-desktop.inputs.nixpkgs.follows = "nixpkgs";
    claude-desktop.inputs.flake-utils.follows = "flake-utils";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      fenix,
      claude-desktop,
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
      claudeDesktop = claude-desktop.packages.${system};

    in
    {
      nixosConfigurations = {
        xenomorph = lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            ./hardware-configuration.nix
            ./xenomorph/configuration.nix
            ./xenomorph/hardware-configuration.nix
          ];
        };
        neomorph = lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            ./hardware-configuration.nix
            ./neomorph/configuration.nix
            ./neomorph/hardware-configuration.nix
          ];
        };
      };
      homeConfigurations = {
        "marco@neomorph" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit unstable rustToolchain claudeDesktop; };
          modules = [
            ./home.nix
            ./neomorph/home.nix
            ./git.nix
            ./report.nix
            ./zsh.nix
            ./foot.nix
            ./rust.nix
          ];
        };
        "marco@xenomorph" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit unstable rustToolchain claudeDesktop; };
          modules = [
            ./home.nix
            ./xenomorph/home.nix
            ./git.nix
            ./report.nix
            ./zsh.nix
            ./ghostty.nix
            ./rust.nix
          ];
        };
      };
    };
}
