# NixOS Configuration Consolidation TODO

This TODO list implements the consolidation plan outlined in `consolidation.md` to modularize the multi-host NixOS configuration following best practices.

## Tasks

### Task 0: Add neomorph SSH key to GPG agent configuration

- [X] Configure neomorph SSH key in GPG agent

**Prompt**: When on the neomorph machine, get the SSH key keygrip and add it to the GPG agent configuration:

1. Run this command on neomorph to get the keygrip:
   ```bash
   gpg-connect-agent 'keyinfo --ssh-list --ssh-fpr' /bye
   ```
2. Add the keygrip to `hosts/neomorph/home.nix`:
   ```nix
   services.gpg-agent = {
     sshKeys = [ "KEYGRIP_FROM_STEP_1" ];
   };
   ```
3. Test with `bin/nix-home` on neomorph
4. Verify SSH key is loaded automatically without `ssh-add`

**Context**: This completes the GPG agent SSH configuration for both hosts. Xenomorph is already configured with keygrip `A18D2A102BDBA1DEED0F4BCE79834B4865124319`.

**Files affected**:
- `hosts/neomorph/home.nix`

---

### Task 1: Create modules directory structure

- [X] Create modular directory structure for better organization

**Prompt**: Create the following directory structure in the nixos repository to organize modules according to NixOS best practices:

```
modules/
├── system/
└── home/
profiles/
hosts/
  ├── xenomorph/
  └── neomorph/
shared/
```

Move the following existing files into the `shared/` directory:
- `git.nix` → `shared/git.nix`
- `zsh.nix` → `shared/zsh.nix`
- `rust.nix` → `shared/rust.nix`
- `report.nix` → `shared/report.nix`

Move the following existing files into appropriate `hosts/` subdirectories:
- `xenomorph/configuration.nix` → `hosts/xenomorph/configuration.nix`
- `xenomorph/home.nix` → `hosts/xenomorph/home.nix`
- `xenomorph/hardware-configuration.nix` → `hosts/xenomorph/hardware-configuration.nix`
- `neomorph/configuration.nix` → `hosts/neomorph/configuration.nix`
- `neomorph/home.nix` → `hosts/neomorph/home.nix`
- `neomorph/hardware-configuration.nix` → `hosts/neomorph/hardware-configuration.nix`
- `neomorph/clamav.nix` → `hosts/neomorph/clamav.nix`

Keep the root-level `configuration.nix`, `home.nix`, `hardware-configuration.nix` where they are for now.

**Files affected**:
- Create: `modules/system/`, `modules/home/`, `profiles/`, `hosts/xenomorph/`, `hosts/neomorph/`, `shared/`
- Move: `git.nix`, `zsh.nix`, `rust.nix`, `report.nix`, all files in `xenomorph/` and `neomorph/` directories

---

### Task 2: Update flake.nix imports for new directory structure

- [X] Update all import paths in flake.nix to reference new locations

**Prompt**: Update `flake.nix` to import modules from their new locations after the directory restructure. Update all paths:

- System modules should now be imported from `hosts/<hostname>/`
- Home-manager shared modules should import from `shared/` instead of root
- Ensure both xenomorph and neomorph configurations work with the new paths

The new import structure should be:
- `./hosts/xenomorph/configuration.nix` (was `./xenomorph/configuration.nix`)
- `./hosts/xenomorph/hardware-configuration.nix` (was `./xenomorph/hardware-configuration.nix`)
- `./hosts/neomorph/configuration.nix` (was `./neomorph/configuration.nix`)
- `./hosts/neomorph/hardware-configuration.nix` (was `./neomorph/hardware-configuration.nix`)
- `./hosts/neomorph/clamav.nix` (was `./neomorph/clamav.nix`)
- `./shared/git.nix` (was `./git.nix`)
- `./shared/zsh.nix` (was `./zsh.nix`)
- `./shared/rust.nix` (was `./rust.nix`)
- `./shared/report.nix` (was `./report.nix`)

Keep `ghostty.nix` in root for now as it will be moved in a later task.

**Files affected**:
- `flake.nix`

---

### Task 3: Extract common Wayland configuration module

- [X] Create shared Wayland module with common configuration

**Prompt**: Create a new module `modules/system/wayland-common.nix` that contains configuration common to both Wayland compositors (Hyprland and Sway). This module should include:

- Common Wayland environment variables
- XDG desktop portal base configuration (gtk portal which both use)
- Common Wayland-related packages that both compositors need
- Shared display manager configuration (SDDM is already in base config)

The module should use `lib.mkIf` to be conditionally enabled. Create an option `wayland.enable` that can be set by host-specific configurations.

Do NOT include compositor-specific packages or configuration (hyprland vs sway specific items). Those will be extracted in separate tasks.

**Files affected**:
- Create: `modules/system/wayland-common.nix`

---

### Task 4: Create Hyprland-specific system module

- [X] Extract Hyprland configuration into dedicated module

**Prompt**: Create a new module `modules/system/hyprland.nix` that contains all Hyprland-specific system configuration extracted from `hosts/xenomorph/configuration.nix`. This should include:

- `programs.hyprland.enable = true`
- `programs.hyprland.withUWSM = true`
- `programs.hyprlock.enable = true`
- `security.pam.services.hyprlock = {}`

The module should have an enable option `programs.hyprland-desktop.enable` that when enabled, sets all the above. After creating this module, update `hosts/xenomorph/configuration.nix` to just set the hostname and import/enable this module instead of duplicating the configuration.

**Files affected**:
- Create: `modules/system/hyprland.nix`
- Modify: `hosts/xenomorph/configuration.nix`

---

### Task 5: Create Sway-specific system module

- [X] Extract Sway configuration into dedicated module

**Prompt**: Create a new module `modules/system/sway.nix` that contains all Sway-specific system configuration extracted from `hosts/neomorph/configuration.nix`. This should include:

- `programs.sway.enable = true`
- `programs.sway.wrapperFeatures.gtk = true`
- `programs.xwayland.enable = true`

The module should have an enable option `programs.sway-desktop.enable` that when enabled, sets all the above. After creating this module, update `hosts/neomorph/configuration.nix` to just set the hostname and import/enable this module instead of duplicating the configuration.

**Files affected**:
- Create: `modules/system/sway.nix`
- Modify: `hosts/neomorph/configuration.nix`

---

### Task 6: Extract ClamAV antivirus module

- [X] Move ClamAV configuration to security module

**Prompt**: Create a new module `modules/system/clamav.nix` that contains the ClamAV antivirus configuration currently in `hosts/neomorph/clamav.nix`. This is a security feature that could be useful on either host, so it should be a reusable module.

The module should:
- Have an enable option `services.clamav-security.enable`
- Include all the ClamAV daemon, updater, scanning service, and timer configurations
- Include the tmpfiles rules for the log directory
- Include clamav in system packages

Move the file from `hosts/neomorph/clamav.nix` to `modules/system/clamav.nix`.

Update `flake.nix` to import `./modules/system/clamav.nix` in the neomorph system modules instead of `./hosts/neomorph/clamav.nix`.

Update `hosts/neomorph/configuration.nix` to enable the module with `services.clamav-security.enable = true;`.

**Files affected**:
- Move: `hosts/neomorph/clamav.nix` → `modules/system/clamav.nix`
- Modify: `modules/system/clamav.nix` (add enable option)
- Modify: `flake.nix`
- Modify: `hosts/neomorph/configuration.nix`

---

### Task 7: Extract common desktop packages module

- [X] Create shared home-manager module for common desktop packages

**Prompt**: Create a new module `modules/home/desktop-common.nix` that contains packages used by both hosts for desktop environments. Extract the following packages from `home.nix` that are desktop-related and common to both:

- blueman
- brightnessctl
- desktop-file-utils
- networkmanagerapplet
- pavucontrol
- playerctl
- wl-clipboard
- rofi
- waybar
- xdg-desktop-portal
- xdg-desktop-portal-gtk

The module should have an enable option `desktop-common.enable`. Keep other packages in `home.nix` if they are general-purpose (not desktop-specific) or move them in later tasks if they are compositor-specific.

**Files affected**:
- Create: `modules/home/desktop-common.nix`

---

### Task 8: Extract GTK theming module with dark/light variants

- [X] Create themed GTK module supporting dark and light variants

**Prompt**: Create a new module `modules/home/gtk-theme.nix` that handles GTK theming configuration with support for both dark and light variants. The module should:

- Define an option `gtk-theme.variant` that accepts "dark" or "light"
- Set `gtk.theme.name` to "Materia-Dark" when variant is "dark", "Materia-light" when "light"
- Set `gtk.iconTheme.name` to "Papirus-Dark" for dark, "Papirus-light" for light
- Set `home.sessionVariables.GTK_THEME` appropriately
- Include the `materia-theme` and `papirus-icon-theme` packages

Then update both host configurations to use this module:
- `hosts/xenomorph/home.nix` should set `gtk-theme.variant = "dark"`
- `hosts/neomorph/home.nix` should set `gtk-theme.variant = "light"`

Remove the duplicate GTK configuration from both host files.

**Files affected**:
- Create: `modules/home/gtk-theme.nix`
- Modify: `hosts/xenomorph/home.nix`, `hosts/neomorph/home.nix`

---

### Task 9: Create XDG portal modules per compositor

- [X] Extract XDG portal configuration into compositor-specific modules

**Prompt**: Create two new home-manager modules for XDG portal configuration:

1. `modules/home/xdg-portal-hyprland.nix` - Contains the xdg.portal config from `hosts/xenomorph/home.nix`:
   - Enable xdg.portal
   - Add xdg-desktop-portal-gtk and xdg-desktop-portal-hyprland to extraPortals
   - Configure common and hyprland-specific portal settings
   - Include xdg-desktop-portal-hyprland in packages

2. `modules/home/xdg-portal-sway.nix` - Contains the xdg.portal config from `hosts/neomorph/home.nix`:
   - Enable xdg.portal
   - Add xdg-desktop-portal-gtk and xdg-desktop-portal-wlr to extraPortals
   - Configure common and sway-specific portal settings
   - Include xdg-desktop-portal-wlr in packages
   - Include the systemd user service for xdg-desktop-portal-wlr

Each module should have an enable option. Update the host configurations to enable the appropriate portal module and remove the duplicated portal configuration.

**Files affected**:
- Create: `modules/home/xdg-portal-hyprland.nix`, `modules/home/xdg-portal-sway.nix`
- Modify: `hosts/xenomorph/home.nix`, `hosts/neomorph/home.nix`

---

### Task 10: Consolidate XDG MIME types configuration

- [X] Create base MIME types with host-specific overrides

**Prompt**: Create a new module `modules/home/xdg-mimetypes.nix` that contains the common XDG MIME type associations shared by both hosts. Extract all the common MIME types from both `hosts/neomorph/home.nix` and root `home.nix`, particularly:

- Web browser associations (brave)
- PDF viewer (evince)
- Image viewer (eog)
- Video player (mpv)
- Archive handler (file-roller)
- Common text associations

Create options for terminal preference so hosts can override:
- `xdg-mimetypes.terminal` option that defaults to "alacritty.desktop"

The module should set `xdg.mimeApps.enable = true` and populate `defaultApplications` with the common set.

Then update both host configs:
- xenomorph should override terminal to "ghostty.desktop"
- neomorph should use the default "alacritty.desktop"

Remove the duplicate MIME type definitions from both host files, keeping only host-specific ones if any remain.

**Files affected**:
- Create: `modules/home/xdg-mimetypes.nix`
- Modify: `hosts/xenomorph/home.nix`, `hosts/neomorph/home.nix`, `home.nix`

---

### Task 11: Move terminal configuration to modules

- [X] Move ghostty.nix into modules directory

**Prompt**: Move the terminal configuration file into the home modules directory:

- Move `ghostty.nix` to `modules/home/terminal-ghostty.nix`

Update `flake.nix` to import from the new location:
- xenomorph should import `./modules/home/terminal-ghostty.nix`

Note: neomorph uses alacritty which is already in the package list, no separate module needed.

**Files affected**:
- Move: `ghostty.nix` → `modules/home/terminal-ghostty.nix`
- Modify: `flake.nix`

---

### Task 12: Extract Hyprland ecosystem packages module

- [X] Create module for Hyprland-specific home packages

**Prompt**: Create a new module `modules/home/hyprland-desktop.nix` that contains all Hyprland-specific packages and services from `hosts/xenomorph/home.nix`:

Packages:
- hyprland, hyprpaper, hypridle, hyprlock, hyprpolkitagent, hyprshot
- swaynotificationcenter
- gnome-keyring, polkit_gnome

Services:
- gnome-keyring (with secrets component)
- network-manager-applet
- hypridle
- hyprpaper

The module should have an enable option `hyprland-desktop.enable`.

Update `hosts/xenomorph/home.nix` to import and enable this module, removing the duplicated package and service definitions.

**Files affected**:
- Create: `modules/home/hyprland-desktop.nix`
- Modify: `hosts/xenomorph/home.nix`

---

### Task 13: Extract Sway ecosystem packages module

- [ ] Create module for Sway-specific home packages

**Prompt**: Create a new module `modules/home/sway-desktop.nix` that contains all Sway-specific packages from `hosts/neomorph/home.nix`:

Packages:
- alacritty (backup terminal)
- dunst (notifications)
- sway
- sway-contrib.grimshot (screenshots)
- swaylock-effects (screen locking)

The module should have an enable option `sway-desktop.enable`.

Update `hosts/neomorph/home.nix` to import and enable this module, removing the duplicated package definitions.

**Files affected**:
- Create: `modules/home/sway-desktop.nix`
- Modify: `hosts/neomorph/home.nix`

---

### Task 14: Create gaming profile module

- [ ] Extract Steam and gaming configuration into profile

**Prompt**: Create a new profile module `profiles/gaming.nix` that contains gaming-related system configuration currently in `hosts/xenomorph/configuration.nix`:

```nix
programs.steam = {
  enable = true;
  remotePlay.openFirewall = true;
  dedicatedServer.openFirewall = true;
  localNetworkGameTransfers.openFirewall = true;
};
```

The module should have an enable option `profiles.gaming.enable`.

Update `hosts/xenomorph/configuration.nix` to import this profile from flake.nix and remove the Steam configuration from the host file.

Update `flake.nix` to import `./profiles/gaming.nix` in the xenomorph system modules list.

**Files affected**:
- Create: `profiles/gaming.nix`
- Modify: `hosts/xenomorph/configuration.nix`, `flake.nix`

---

### Task 15: Create work profile module

- [ ] Extract work-specific packages into profile

**Prompt**: Create a new profile module `profiles/work.nix` that contains work-related packages currently in `hosts/neomorph/home.nix`:

This should include the desktop entries for:
- Slack (DEFRA Digital Team)
- Slack (DEFRA Digital)
- Slack (Equal Experts)
- Google Meet

The module should have an enable option `profiles.work.enable` and contain the xdg.desktopEntries configuration.

Update `hosts/neomorph/home.nix` to import this profile from flake.nix and remove the desktop entries.

Update `flake.nix` to import `./profiles/work.nix` in the neomorph home modules list.

**Files affected**:
- Create: `profiles/work.nix`
- Modify: `hosts/neomorph/home.nix`, `flake.nix`

---

### Task 16: Create music production profile module

- [ ] Extract music production packages into profile

**Prompt**: Create a new profile module `profiles/music-production.nix` that contains music-related packages and desktop entries from `hosts/xenomorph/home.nix`:

Packages:
- ardour
- musescore
- transcribe
- ffmpeg
- yt-dlp

Desktop entries:
- moises (music studio web app)

The module should have an enable option `profiles.music-production.enable`.

Update `hosts/xenomorph/home.nix` to import this profile from flake.nix and remove the music-related packages and desktop entries.

Update `flake.nix` to import `./profiles/music-production.nix` in the xenomorph home modules list.

**Files affected**:
- Create: `profiles/music-production.nix`
- Modify: `hosts/xenomorph/home.nix`, `flake.nix`

---

### Task 17: Consolidate session variables

- [ ] Extract common session variables to shared module

**Prompt**: Create a new module `modules/home/session-variables.nix` that contains session variables common to both hosts from `home.nix`:

- EDITOR = "nvim"
- POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = "true"
- QT_QPA_PLATFORM = "wayland;xcb"
- QT_QPA_PLATFORMTHEME = "qt6ct"
- XCURSOR_SIZE = "24"
- XCURSOR_THEME = "Bibata-Modern-Ice"
- NIXPKGS_ALLOW_UNFREE = 1 (from neomorph, should be common)

The module should have an enable option defaulting to true.

Add host-specific session variables to host configs:
- neomorph: XDG_SCREENSHOTS_DIR = "$HOME/Pictures/Screenshots"
- xenomorph: none currently

Update `flake.nix` to import this module for both hosts and remove session variables from `home.nix` and `hosts/neomorph/home.nix`.

**Files affected**:
- Create: `modules/home/session-variables.nix`
- Modify: `home.nix`, `hosts/neomorph/home.nix`, `flake.nix`

---

### Task 18: Update flake.nix with all new module imports

- [ ] Final flake.nix update to import all new modules

**Prompt**: Update `flake.nix` to import all newly created modules in the appropriate host configurations. The import structure should follow this pattern:

For xenomorph NixOS system:
- Base configs (configuration.nix, hardware-configuration.nix from both root and host)
- `./modules/system/wayland-common.nix`
- `./modules/system/hyprland.nix`
- `./profiles/gaming.nix`

For neomorph NixOS system:
- Base configs (configuration.nix, hardware-configuration.nix from both root and host)
- `./modules/system/wayland-common.nix`
- `./modules/system/sway.nix`
- `./modules/system/clamav.nix`

For xenomorph home-manager:
- Base home.nix (root and host)
- Shared modules from `./shared/` (git, zsh, rust, report)
- `./modules/home/desktop-common.nix`
- `./modules/home/gtk-theme.nix`
- `./modules/home/xdg-mimetypes.nix`
- `./modules/home/xdg-portal-hyprland.nix`
- `./modules/home/hyprland-desktop.nix`
- `./modules/home/terminal-ghostty.nix`
- `./modules/home/session-variables.nix`
- `./profiles/music-production.nix`

For neomorph home-manager:
- Base home.nix (root and host)
- Shared modules from `./shared/` (git, zsh, rust, report)
- `./modules/home/desktop-common.nix`
- `./modules/home/gtk-theme.nix`
- `./modules/home/xdg-mimetypes.nix`
- `./modules/home/xdg-portal-sway.nix`
- `./modules/home/sway-desktop.nix`
- `./modules/home/session-variables.nix`
- `./profiles/work.nix`

Ensure all paths are correct and the flake builds successfully for both hosts.

**Files affected**:
- `flake.nix`

---

### Task 19: Clean up host configuration files

- [ ] Remove duplicated configuration from host-specific files

**Prompt**: Clean up the host-specific configuration files to remove all duplicated code that has been extracted to modules. After all the previous tasks, the host files should be minimal and only contain:

`hosts/xenomorph/configuration.nix`:
- hostname setting
- Enable options for imported modules

`hosts/neomorph/configuration.nix`:
- hostname setting
- Enable options for imported modules

`hosts/xenomorph/home.nix`:
- Any remaining xenomorph-specific packages not extracted (ansible, doctl, discord)
- Enable options for imported modules
- Theme variant setting (dark)
- Terminal preference (ghostty)

`hosts/neomorph/home.nix`:
- obs-studio package (specific to neomorph)
- Enable options for imported modules
- Theme variant setting (light)
- Terminal preference (alacritty)

Remove all configuration that has been moved to shared modules, keeping only true host-specific settings and module enable options.

**Files affected**:
- `hosts/xenomorph/configuration.nix`
- `hosts/xenomorph/home.nix`
- `hosts/neomorph/configuration.nix`
- `hosts/neomorph/home.nix`

---

### Task 20: Test consolidated configuration on both hosts

- [ ] Build and test the new modular configuration

**Prompt**: Test that the newly consolidated configuration builds and works correctly on both hosts:

1. Stage all new and modified files with git
2. For xenomorph:
   - Run `bin/nix-home` to rebuild home-manager config
   - Run `bin/nix-system` to rebuild system config
   - Verify Hyprland starts correctly
   - Verify all applications and services work
3. For neomorph:
   - Run `bin/nix-home` to rebuild home-manager config
   - Run `bin/nix-system` to rebuild system config
   - Verify Sway starts correctly
   - Verify all applications and services work

Document any issues found and create follow-up tasks if needed. Only proceed to commit if both hosts build and function correctly.

**Files affected**:
- All created and modified files from previous tasks

---

### Task 21: Document the new module structure

- [ ] Add documentation for the new modular structure

**Prompt**: Update the `CLAUDE.md` file to document the new modular structure. Add a section explaining:

- The purpose of each directory (modules/, profiles/, hosts/, shared/)
- How to add a new host using the modular structure
- How to enable/disable profiles and modules
- Examples of host-specific vs shared configuration
- Guidelines for when to create a new module vs adding to existing

Also add a comment block at the top of each newly created module explaining:
- What the module does
- What options it provides
- Example usage

Keep documentation concise and practical.

**Files affected**:
- `CLAUDE.md`
- All module files in `modules/`, `profiles/`

---

### Task 22: Fix GTK theme name capitalization

- [ ] Correct Materia-Dark to Materia-dark

**Prompt**: Fix the GTK theme name capitalization in xenomorph configuration. The correct theme name is "Materia-dark" with a lowercase 'd', not "Materia-Dark".

Update the following in `xenomorph/home.nix`:
- Change `gtk.theme.name` from "Materia-Dark" to "Materia-dark"
- Change `home.sessionVariables.GTK_THEME` from "Materia-Dark" to "Materia-dark"

Also update the documentation files to reflect the correct capitalization:
- Update `consolidation.md` references to use "Materia-dark"
- Update `TODO.md` Task 7 to use "Materia-dark" instead of "Materia-Dark"

**Files affected**:
- `xenomorph/home.nix`
- `consolidation.md`
- `TODO.md`

---

## Execution plan workflow

The following workflow applies when executing this TODO list:
- Execute one task at a time in order
- Implement the task in **THE SIMPLEST WAY POSSIBLE**
- Stage new files with git before testing: `git add <files>`
- Test the changes by running the appropriate build commands:
  - For system changes: User runs `bin/nix-system` manually
  - For home changes: User runs `bin/nix-home` manually
- Format the code: `nixfmt **/*.nix`
- **Ask me to review the task once you have completed and then WAIT FOR ME**
- Mark the TODO item as complete with [X] after user approval
- User will commit the changes using Git Guy
- Move on to the next task
