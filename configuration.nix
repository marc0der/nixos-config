# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest; # Install latest stable kernel

  # Disable integrated camera GPIO driver to fix boot errors and shutdown hang
  # The IPU6 camera doesn't work properly on Linux anyway, and the broken driver
  # causes GPIO errors and prevents clean shutdown. External USB cameras unaffected.
  boot.blacklistedKernelModules = [
    "int3472"
    "intel_skl_int3472"
  ];

  # Networking
  networking.networkmanager = {
    enable = true;
    settings = {
      connectivity = {
        uri = "http://nmcheck.gnome.org/check_network_status.txt";
        interval = 60;
        enabled = true;
      };
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Nix settings
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Console configuration
  console.keyMap = "uk";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.marco = {
    isNormalUser = true;
    description = "Marco Vermeulen";
    extraGroups = [
      "dialout"
      "docker"
      "input"
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
    packages = [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Override 1Password to use Wayland natively with Ozone platform
  nixpkgs.config.packageOverrides = pkgs: {
    _1password-gui = pkgs._1password-gui.overrideAttrs (oldAttrs: {
      postFixup = (oldAttrs.postFixup or "") + ''
        # Wrap the 1password binary to add Ozone Wayland flags
        wrapProgram $out/bin/1password \
          --add-flags "--ozone-platform-hint=auto" \
          --add-flags "--enable-features=WaylandWindowDecorations"
      '';
    });
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bzip2
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

  # Firefox
  programs.firefox.enable = true;

  # Security
  security.pam.services.sddm.enableGnomeKeyring = true;

  # Display server and manager
  services.xserver = {
    enable = true;
    xkb = {
      layout = "gb";
      variant = "";
    };
  };

  # Display manager (SDDM)
  services.displayManager.sddm = {
    enable = true;
    theme = "breeze";
  };

  # User accounts service
  services.accounts-daemon.enable = true;

  # Printing
  services.printing = {
    enable = true;
    drivers = with pkgs; [ cups-brother-hll2350dw ];
    browsing = true;
    defaultShared = true;
    listenAddresses = [ "*:631" ];
    allowFrom = [ "all" ];
    startWhenNeeded = true;
  };

  # Network discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  # Power management
  services.power-profiles-daemon.enable = true;

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
    settings = {
      Login = {
        IdleAction = "ignore";
        HandlePowerKey = "ignore";
      };
    };
  };

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.pipewire.wireplumber.extraConfig."10-bluez" = {
    "monitor.bluez.properties" = {
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-msbc" = true;
      "bluez5.enable-hw-volume" = true;
      "bluez5.roles" = [
        "hsp_hs"
        "hsp_ag"
        "hfp_hf"
        "hfp_ag"
        "a2dp_sink"
        "a2dp_source"
      ];
      "bluez5.codecs" = [
        "bc"
        "sbc_xq"
        "aac"
        "ldac"
        "aptx"
        "aptx_hd"
        "aptx_ll"
      ];
    };
  };

  # Remote access
  services.openssh.enable = true;

  # Virtual filesystems
  services.gvfs.enable = true;

  # Hardware configuration
  services.udev.extraRules = ''
    # Keychron K3 Pro - specific product ID
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0231", MODE="0664", GROUP="dialout"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0231", MODE="0664", GROUP="dialout"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0231", MODE="0664", GROUP="dialout"
  '';

  systemd.services.battery-charge-threshold = {
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    startLimitBurst = 0;
    description = "Sets a battery charge end threshold";
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold' ";
    };
  };

  # Password manager
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "marco" ];
  };

  # Application platforms
  services.flatpak.enable = true;

  # Virtualization
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # System reporting
  system.activationScripts.changes-report.text = ''
    export PATH=${pkgs.nix}/bin:$PATH
    ${pkgs.nvd}/bin/nvd diff /run/current-system /nix/var/nix/profiles/system
  '';

  # Firewall configuration
  networking.firewall = {
    enable = true;
    # Allow SSH
    allowedTCPPorts = [ 22 ];
    # Allow common local network services
    allowedUDPPorts = [ ];
    # Trust local network interfaces (adjust ranges as needed)
    trustedInterfaces = [ "lo" ];
    # Allow ping
    allowPing = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
