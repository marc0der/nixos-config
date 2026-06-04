# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Disable Intel IPU6 integrated camera (unsupported, breaks Zoom)
  local.hardware.disable-ipu6-camera.enable = true;

  # Networking: NetworkManager + firewall
  local.networking-stack.enable = true;

  # Locale, time zone, console keymap
  local.locale-en-gb.enable = true;

  # Nix daemon: flakes + numtide substituter
  local.nix-settings.enable = true;

  # User account: marco
  local.users-marco.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Password manager: 1Password (Wayland-native)
  local.onepassword.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    bzip2
    btop
    cage
    cmake
    fragments
    gcc
    git
    gzip
    intel-media-driver
    killall
    libnotify
    nmap
    nnn
    neovim
    nvd
    pciutils
    power-profiles-daemon
    rclone
    tree
    unzip
    usbutils
    zip
  ];

  # System programs
  programs.mtr.enable = true;
  programs.gnupg.agent.enable = true;
  programs.zsh.enable = true;
  programs.nix-ld.enable = true;
  programs.fuse.userAllowOther = true;

  # Security: SDDM keyring, chromium SUID sandbox, passwordless rebuild sudo
  security.pam.services.sddm.enableGnomeKeyring = true;
  security.chromiumSuidSandbox.enable = true;
  security.sudo.extraRules = [
    {
      users = [ "marco" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [
            "NOPASSWD"
            "SETENV"
          ];
        }
        {
          command = "/run/current-system/sw/bin/nix";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Keyboard layout: gbx (UK + literal backtick)
  local.keyboard-gbx.enable = true;

  # Display manager: SDDM
  services.displayManager.sddm = {
    enable = true;
    theme = "breeze";
  };

  # User accounts service
  services.accounts-daemon.enable = true;

  # Printing: CUPS + Brother driver + Avahi
  local.printing.enable = true;

  # Power management: profiles + logind + battery cap
  local.power-management.enable = true;

  # Audio: PipeWire + Bluetooth codec tuning
  local.audio-pipewire.enable = true;

  # Remote access: OpenSSH with X11 forwarding
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
    };
  };

  # Virtual filesystems
  services.gvfs.enable = true;

  # Keychron K3 Pro udev rules
  local.keychron-udev.enable = true;

  # Application platforms
  services.flatpak.enable = true;

  # Virtualisation: Docker
  virtualisation.docker.enable = true;

  # System reporting: nvd diff on activation
  system.activationScripts.changes-report.text = ''
    export PATH=${pkgs.nix}/bin:$PATH
    ${pkgs.nvd}/bin/nvd diff /run/current-system /nix/var/nix/profiles/system
  '';

  # NixOS release version
  # Pinned to original install (24.11); deliberately not bumped with channel.
  system.stateVersion = "24.11";

}
