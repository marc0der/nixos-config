{
  description = "Modular NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      fenix,
      llm-agents,
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
      llmAgents = llm-agents.packages.${system};

      # Home-manager modules shared by every host. Host-specific modules
      # (compositor, xdg-portal, host home.nix, host-only profiles) are
      # appended in each homeConfigurations entry below.
      commonHomeModules = [
        ./home.nix
        ./shared/git.nix
        ./shared/report.nix
        ./shared/tmux.nix
        ./shared/zsh.nix
        ./shared/rust.nix
        ./modules/home/terminal-ghostty.nix
        ./modules/home/ssh-config.nix
        ./modules/home/desktop-common.nix
        ./modules/home/gtk-theme.nix
        ./modules/home/xdg-mimetypes.nix
        ./modules/home/session-variables.nix
        ./modules/home/home-scripts.nix
        ./profiles/music-production.nix
      ];

      commonHomeExtraSpecialArgs = {
        inherit
          unstable
          rustToolchain
          llmAgents
          ;
      };

    in
    {
      formatter.${system} = pkgs.nixfmt;

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
            ./modules/system/tailscale.nix
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
          extraSpecialArgs = commonHomeExtraSpecialArgs;
          modules = commonHomeModules ++ [
            ./hosts/neomorph/home.nix
            ./modules/home/xdg-portal-sway.nix
            ./modules/home/sway-desktop.nix
            ./modules/home/sway-config.nix
            ./modules/home/sway-rules.nix
            ./modules/home/sway-keybindings.nix
            ./modules/home/sway-startup.nix
            ./profiles/work.nix
          ];
        };
        "marco@xenomorph" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = commonHomeExtraSpecialArgs;
          modules = commonHomeModules ++ [
            ./hosts/xenomorph/home.nix
            ./modules/home/xdg-portal-hyprland.nix
            ./modules/home/hyprland-desktop.nix
            ./modules/home/hyprland-config.nix
            ./modules/home/hyprland-rules.nix
            ./modules/home/hyprland-keybindings.nix
            ./modules/home/hyprland-startup.nix
            ./modules/home/hyprland-extras.nix
          ];
        };
      };
    };
}
