# NixOS Multi-Host Configuration Consolidation Analysis

## Overview
This document analyzes the current state of the neomorph and xenomorph NixOS configurations, identifying overlaps, differences, and opportunities for consolidation following NixOS best practices.

Both hosts are Lenovo X1 Carbon laptops with identical hardware configurations but different use cases and desktop environments.

## Current Structure

### Shared Configuration (Both Hosts)
Both hosts currently share:
- **Base system**: `configuration.nix` - Core system settings, bootloader, networking, users, services
- **Base home**: `home.nix` - Core user packages, fonts, GTK themes, XDG settings, Claude MCP setup
- **Common modules**:
  - `git.nix` - Git configuration with GPG signing
  - `report.nix` - System changes reporting
  - `zsh.nix` - ZSH shell configuration with powerlevel10k
  - `rust.nix` - Rust toolchain via Fenix

### Host-Specific System Configuration

#### xenomorph (Development/Music/Gaming Laptop)
**System** (`xenomorph/configuration.nix`):
- Wayland compositor: Hyprland with UWSM
- Programs: hyprlock, Steam (with all firewall exceptions)
- Personal development and entertainment setup

**Home** (`xenomorph/home.nix`):
- Terminal: Ghostty (referenced in flake.nix)
- Theme: Materia-Dark with Papirus-Dark icons
- Desktop portals: xdg-desktop-portal-hyprland + gtk
- Packages: Gaming/music tools (ansible, ardour, discord, doctl, ffmpeg, musescore, transcribe, yt-dlp)
- Hyprland ecosystem: hyprland, hyprpaper, hypridle, hyprlock, hyprpolkitagent, hyprshot
- Notification: swaynotificationcenter
- Services: gnome-keyring, network-manager-applet, hypridle, hyprpaper (managed by UWSM)
- Desktop entries: moises (music studio)

#### neomorph (Work/Laptop)
**System** (`neomorph/configuration.nix`):
- Wayland compositor: Sway
- Minimal system configuration
- Extra module: `clamav.nix` - Antivirus with daily scans

**Home** (`neomorph/home.nix`):
- Terminal: Alacritty
- Theme: Materia-light with Papirus-light icons
- Desktop portals: xdg-desktop-portal-wlr + gtk
- Packages: alacritty, dunst, obs-studio, sway, grimshot, swaylock-effects
- Session variables: XDG_SCREENSHOTS_DIR, NIXPKGS_ALLOW_UNFREE
- Desktop entries: Multiple Slack workspaces (DEFRA Digital Team, DEFRA Digital, Equal Experts), Google Meet
- Service: xdg-desktop-portal-wlr systemd service

## Key Differences Summary

| Aspect | xenomorph | neomorph |
|--------|-----------|----------|
| **Primary Use** | Development/Music/Gaming | Work |
| **Compositor** | Hyprland + UWSM | Sway |
| **Terminal** | Ghostty | Alacritty |
| **Theme** | Dark (Materia-Dark) | Light (Materia-light) |
| **Gaming** | Steam enabled | No gaming |
| **Security** | Standard | ClamAV antivirus |
| **Work Apps** | Music production | Slack, Google Meet |
| **Desktop Portal** | hyprland + gtk | wlr + gtk |
| **Notifications** | swaynotificationcenter | dunst |
| **Screen Lock** | hyprlock | swaylock-effects |
| **Screenshot** | hyprshot | grimshot |

## Overlapping Configuration (Opportunities for Consolidation)

### 1. **Duplicate Package Lists**
Both hosts define their own package lists, but several packages could be shared:
- Common Wayland/desktop tools (defined differently per compositor)
- Theme packages (both use materia-theme and papirus-icon-theme, just different variants)

### 2. **XDG Configuration**
- Both hosts define `xdg.portal` configuration (different portals per compositor)
- Both define `xdg.mimeApps` (slightly different, could be unified with host-specific overrides)
- GTK theming structure is identical, only theme name differs

### 3. **Session Variables**
- Some overlap exists (GTK_THEME set in both, NIXPKGS_ALLOW_UNFREE only in neomorph but should be shared)

### 4. **Desktop Entries**
- Pattern of creating Brave-based web apps exists on both hosts but for different services
- Could be modularized

## Best Practices for Multi-Host NixOS Configuration

Based on the NixOS community best practices, here's the recommended structure:

### Recommended Directory Structure
```
nixos/
├── flake.nix                    # Flake entry point
├── modules/                     # Reusable modules
│   ├── system/                  # System-level modules
│   │   ├── common.nix          # Shared system config
│   │   ├── wayland-common.nix  # Shared Wayland config
│   │   ├── hyprland.nix        # Hyprland-specific
│   │   └── sway.nix            # Sway-specific
│   └── home/                    # Home-manager modules
│       ├── common.nix          # Shared home config
│       ├── desktop-common.nix  # Shared desktop config
│       ├── terminal-ghostty.nix # Ghostty terminal
│       └── desktop-entries.nix # Desktop entry patterns
├── hosts/                       # Host-specific configs
│   ├── xenomorph/
│   │   ├── configuration.nix   # System config
│   │   ├── hardware-configuration.nix
│   │   └── home.nix            # User config
│   └── neomorph/
│       ├── configuration.nix   # System config
│       ├── hardware-configuration.nix
│       ├── home.nix            # User config
│       └── clamav.nix          # Host-specific module
├── profiles/                    # Use-case profiles
│   ├── gaming.nix              # Gaming packages/config
│   ├── work.nix                # Work-related config
│   └── music-production.nix   # Music tools
└── shared/                      # Current shared modules
    ├── git.nix
    ├── zsh.nix
    ├── rust.nix
    └── report.nix
```

### Key Principles

1. **Separation of Concerns**
   - System configuration (NixOS) separate from user configuration (home-manager)
   - Host-specific settings in `hosts/`
   - Reusable modules in `modules/`
   - Use-case profiles in `profiles/`

2. **DRY (Don't Repeat Yourself)**
   - Extract common configuration to shared modules
   - Use options and conditionals for variations
   - Create themed variants using module options

3. **Composability**
   - Small, focused modules that do one thing well
   - Compose complex configurations from simple building blocks
   - Use imports strategically in flake.nix

4. **Host-Specific Overrides**
   - Keep host directories minimal - only true host-specific config
   - Use imports to compose from shared modules
   - Override shared defaults where needed

## Consolidation Opportunities

### High Priority
1. **Extract common Wayland configuration** - Both use Wayland compositors with similar needs
2. **Unify XDG MIME types** - Create base with host-specific overrides
3. **Consolidate GTK theming** - Use options for dark/light variants
4. **Share desktop portal patterns** - Compositor-agnostic base with specific portals per host
5. **Unify package management** - Base packages + host-specific additions

### Medium Priority
6. **Create terminal module** - ghostty.nix as optional module
7. **Modularize desktop entries** - Pattern for Brave web apps
8. **Session variables consolidation** - Move common vars to shared config

### Low Priority (Keep Separate)
- Hardware-specific configuration (already separate)
- ClamAV (neomorph-specific security requirement)
- Steam (xenomorph-specific gaming)
- Work-specific desktop entries (Slack, Meet)

## Implementation Strategy

1. **Create modules/ directory structure**
   - Don't touch existing configs yet
   - Build new modular structure alongside

2. **Extract common configuration incrementally**
   - Start with smallest, most isolated modules
   - Test each extraction on both hosts
   - Move one module at a time

3. **Update flake.nix imports**
   - Update imports to use new module paths
   - Keep backwards compatibility during transition

4. **Remove duplicated code**
   - Only after new modules are tested and working
   - Remove old code from host-specific configs

5. **Document module options**
   - Add comments to explain options
   - Create examples for each module

## Benefits of Consolidation

1. **Maintainability**: Changes to shared functionality only need to be made once
2. **Consistency**: Ensures both hosts follow the same patterns
3. **Testability**: Easier to test individual modules
4. **Scalability**: Adding a third host becomes trivial
5. **Clarity**: Clear separation between host-specific and shared config
6. **Reusability**: Modules can be shared with community or other projects
