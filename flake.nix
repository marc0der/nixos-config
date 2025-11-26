{
  description = "Modular NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
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
            ./hosts/xenomorph/configuration.nix
            ./hosts/xenomorph/hardware-configuration.nix
            ./modules/system/wayland-common.nix
            ./modules/system/hyprland.nix
            ./profiles/gaming.nix
          ];
        };
        neomorph = lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            ./hardware-configuration.nix
            ./hosts/neomorph/configuration.nix
            ./hosts/neomorph/hardware-configuration.nix
            ./modules/system/clamav.nix
            ./modules/system/wayland-common.nix
            ./modules/system/sway.nix
          ];
        };
      };
      homeConfigurations = {
        "marco@neomorph" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit unstable rustToolchain claudeDesktop; };
          modules = [
            ./home.nix
            ./hosts/neomorph/home.nix
            ./shared/git.nix
            ./shared/report.nix
            ./shared/zsh.nix
            ./modules/home/terminal-ghostty.nix
            ./shared/rust.nix
            ./modules/home/desktop-common.nix
            ./modules/home/gtk-theme.nix
            ./modules/home/xdg-portal-sway.nix
            ./modules/home/xdg-mimetypes.nix
            ./modules/home/sway-desktop.nix
            ./modules/home/sway-config.nix
            ./modules/home/sway-rules.nix
            ./modules/home/sway-keybindings.nix
            ./profiles/music-production.nix
            ./profiles/work.nix
          ];
        };
        "marco@xenomorph" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit unstable rustToolchain claudeDesktop; };
          modules = [
            ./home.nix
            ./hosts/xenomorph/home.nix
            ./shared/git.nix
            ./shared/report.nix
            ./shared/zsh.nix
            ./modules/home/terminal-ghostty.nix
            ./shared/rust.nix
            ./modules/home/desktop-common.nix
            ./modules/home/gtk-theme.nix
            ./modules/home/xdg-portal-hyprland.nix
            ./modules/home/xdg-mimetypes.nix
            ./modules/home/hyprland-desktop.nix
            ./profiles/music-production.nix
          ];
        };
      };
    };
}
