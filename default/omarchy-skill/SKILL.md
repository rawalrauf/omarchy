---
name: omarchy
description: >
  REQUIRED for end-user customization of Linux desktop, window manager, or system config.
  Use when editing ~/.config/niri/, ~/.config/waybar/, ~/.config/walker/,
  ~/.config/alacritty/, ~/.config/foot/, ~/.config/kitty/, ~/.config/ghostty/, ~/.config/mako/,
  or ~/.config/omarchy/. Triggers: niri, window rules, keybindings, monitors, gaps, borders,
  opacity, waybar, walker, terminal config, themes, wallpaper, night light, idle, lock screen,
  screenshots, layer rules, workspace settings, display config, and user-facing omarchy commands.
  Excludes Omarchy source development in ~/.local/share/omarchy/ and `omarchy dev` workflows.
---

# Omarchy Skill

Manage a custom niri-based Arch Linux system built on top of [Omarchy](https://omarchy.org/).

This is a fork of DHH's omarchy — migrated from Hyprland to **niri** as the Wayland compositor.
This skill is for end-user customization on installed systems only.
It is NOT for contributing to Omarchy source code.

## When This Skill MUST Be Used

**ALWAYS invoke this skill for end-user requests involving ANY of these:**

- Editing ANY file in `~/.config/niri/` (window rules, keybindings, monitors, looknfeel, etc.)
- Editing ANY file in `~/.config/waybar/`, `~/.config/walker/`, `~/.config/mako/`
- Editing terminal configs (alacritty, foot, kitty, ghostty)
- Editing ANY file in `~/.config/omarchy/`
- Window behavior, opacity, gaps, borders, layer rules, workspace settings
- Themes, wallpapers, fonts, appearance changes
- Display/monitor configuration, mirror mode
- Screenshots, screen recording, reminders, night light, idle behavior, lock screen
- User-facing `omarchy` commands

**If you're about to edit a config file in ~/.config/ on this system, STOP and use this skill first.**

**Do NOT use this skill for Omarchy source development** (editing files in `~/.local/share/omarchy/`).

## Critical Safety Rules

**NEVER modify anything in `~/.local/share/omarchy/`** — reading is safe and encouraged.

This directory is managed by git. Changes will be lost on `omarchy update` and cause conflicts.

```
~/.local/share/omarchy/     # READ-ONLY - NEVER EDIT (reading is OK)
├── bin/                    # Source scripts (symlinked to PATH)
├── config/                 # Default config templates
├── default/niri/           # Niri defaults (sourced by user config via include)
├── themes/                 # Stock themes
├── migrations/             # Update migrations
└── install/                # Installation scripts
```

**Always use these safe locations instead:**
- `~/.config/` — user configuration (safe to edit)
- `~/.config/omarchy/themes/<custom-name>/` — custom themes
- `~/.config/omarchy/hooks/` — custom automation hooks

## System Architecture

| Component | Purpose | Config Location |
|-----------|---------|-----------------|
| **Arch Linux** | Base OS | `/etc/`, `~/.config/` |
| **niri** | Wayland compositor/WM | `~/.config/niri/` |
| **Waybar** | Status bar | `~/.config/waybar/` |
| **Walker** | App launcher | `~/.config/walker/` |
| **Alacritty/Foot/Kitty/Ghostty** | Terminals | `~/.config/<terminal>/` |
| **Mako** | Notifications | `~/.config/mako/` |
| **SwayOSD** | On-screen display | `~/.config/swayosd/` |
| **swayidle** | Idle management | `~/.config/swayidle/` |
| **hyprlock** | Lock screen | `~/.config/hypr/hyprlock.conf` |

## Niri Config Architecture

Niri config uses KDL format. The user's `~/.config/niri/config.kdl` is the entry point — it sources everything via `include` directives:

```
~/.config/niri/
├── config.kdl          # Entry point — includes everything below
├── autostart.kdl       # Startup applications
├── monitors.kdl        # Display/monitor configuration
├── input.kdl           # Keyboard, mouse, touchpad settings
├── bindings.kdl        # Keybindings (sourced from default + user overrides)
├── looknfeel.kdl       # Appearance (gaps, borders, animations, opacity)
├── flags.kdl           # Optional toggle includes (gaps, transparency, mirror, etc.)
└── system.kdl          # Window rules (floating, fullscreen, etc.)
```

**Key architecture detail:** Omarchy defaults live in `~/.local/share/omarchy/default/niri/` and are included by `config.kdl` via:
```kdl
include "~/.local/share/omarchy/default/niri/default.kdl"
```

User files in `~/.config/niri/` override/extend the defaults. Edit those — not the defaults.

### Niri Reload

Niri does NOT auto-reload on save. Always reload after config changes:

```bash
omarchy restart niri         # or: niri msg action load-config-file
```

Always validate config before reloading:
```bash
niri validate --config ~/.config/niri/config.kdl
```

If validation fails, fix errors before reloading.

### Niri Toggles

Toggles are managed via flag files in `~/.local/state/omarchy/toggles/` and KDL snippets in `~/.local/share/omarchy/default/niri/toggles/`. The `flags.kdl` optionally includes them.

Current toggles and their binds:
- `Mod+Backspace` — window transparency
- `Mod+Alt+Backspace` — window gaps
- `Mod+Alt+Delete` — laptop display toggle
- `Mod+Alt+Shift+Delete` — mirror display
- `Mod+Alt+W` — top bar (waybar)
- `Mod+Alt+Shift+W` — top bar transparency
- `Mod+Alt+I` — idle lock
- `Mod+Alt+Period` — toggle menu

## Keybinding Conventions

```
Mod = Super key

Mod+Space               — app launcher (walker)
Mod+Alt+Space           — omarchy menu
Mod+Alt+<letter>        — utilities, toggles, menus
Mod+Shift+<letter>      — launch apps
Mod+Shift+Ctrl+<letter> — TUI controls
Mod+Ctrl+<letter>       — tiling controls
```

**When adding keybindings**, edit `~/.config/niri/bindings.kdl`. Check for conflicts first:
```bash
grep -r "Mod" ~/.config/niri/bindings.kdl ~/.local/share/omarchy/default/niri/bindings/
```

Niri keybind format:
```kdl
binds {
  Mod+E { spawn "nautilus"; }
  Mod+Shift+Q { close-window; }
}
```

## Waybar

```
~/.config/waybar/
├── config.jsonc        # Bar layout and modules
└── style.css           # Styling (transparent.css dynamically imported by toggle)
```

Waybar does NOT auto-reload. After any config change:
```bash
omarchy restart waybar
```

The waybar transparency toggle dynamically adds/removes a `transparent.css` import and sends `SIGUSR2` for CSS reload — no full restart needed for that specific toggle.

## Command Discovery

```bash
omarchy commands                  # List all commands
omarchy <group> --help            # Commands in a group
omarchy commands --json           # Machine-readable listing
cat $(which omarchy-theme-set)    # Read a command's source
```

### Command Groups

| Group | Purpose | Example |
|-------|---------|---------|
| `omarchy refresh` | Reset config to defaults (backs up first) | `omarchy refresh niri` |
| `omarchy restart` | Restart a service/app | `omarchy restart waybar` |
| `omarchy toggle` | Toggle feature on/off | `omarchy toggle nightlight` |
| `omarchy theme` | Theme management | `omarchy theme set <name>` |
| `omarchy install` | Install optional software | `omarchy install docker` |
| `omarchy launch` | Launch apps | `omarchy launch browser` |
| `omarchy capture` | Screenshots and recordings | `omarchy capture screenshot` |
| `omarchy reminder` | Desktop notification reminders | `omarchy reminder 15 "Call back"` |
| `omarchy pkg` | Package management | `omarchy pkg add <pkg>` |
| `omarchy setup` | Setup wizards | `omarchy setup fingerprint` |
| `omarchy update` | System updates | `omarchy update` |
| `omarchy niri` | Niri-specific controls | `omarchy niri monitor mirror` |

## Configuration Locations

### Niri (Window Manager)

Edit files in `~/.config/niri/` — never in `~/.local/share/omarchy/default/niri/`.

Key files:
- `monitors.kdl` — display configuration
- `input.kdl` — keyboard/touchpad/mouse
- `bindings.kdl` — keybindings
- `looknfeel.kdl` — gaps, borders, animations, opacity
- `autostart.kdl` — startup apps
- `window-rules.kdl` — window rules

### Other Configs

| App | Location |
|-----|----------|
| btop | `~/.config/btop/btop.conf` |
| fastfetch | `~/.config/fastfetch/config.jsonc` |
| lazygit | `~/.config/lazygit/config.yml` |
| starship | `~/.config/starship.toml` |
| git | `~/.config/git/config` |
| walker | `~/.config/walker/config.toml` |
| hyprlock | `~/.config/hypr/hyprlock.conf` |

## Safe Customization Patterns

### Pattern 1: Edit User Config Directly

```bash
# 1. Read current config
cat ~/.config/niri/bindings.kdl

# 2. Make changes with Edit tool

# 3. Validate
niri validate --config ~/.config/niri/config.kdl

# 4. Reload
omarchy restart niri
```

### Pattern 2: Make a New Theme

1. Create a directory under `~/.config/omarchy/themes/`
2. See how an existing theme is done: `ls ~/.local/share/omarchy/themes/catppuccin/`
3. Add backgrounds and a `colors.toml` matching the theme format
4. Apply: `omarchy theme set "Name of new theme"`

### Pattern 3: Use Hooks for Automation

```bash
~/.config/omarchy/hooks/
├── theme-set        # Runs after theme change (receives theme name as $1)
├── font-set         # Runs after font change
└── post-update      # Runs after omarchy update
```

### Pattern 4: Reset to Defaults — ALWAYS SEEK USER CONFIRMATION FIRST

```bash
omarchy refresh niri          # Reset all niri configs (backs up first)
omarchy refresh waybar        # Reset waybar config
omarchy refresh walker        # Reset walker config
```

## Common Tasks

### Themes

```bash
omarchy theme list              # Show available themes
omarchy theme current           # Show current theme
omarchy theme set <name>        # Apply theme (use "Tokyo Night" not "tokyo-night")
omarchy theme bg next           # Cycle wallpaper
omarchy theme install <url>     # Install from git repo
```

### Display/Monitors

Edit `~/.config/niri/monitors.kdl`. List monitors:
```bash
niri msg outputs
```

Niri monitor format:
```kdl
output "eDP-1" {
  mode "1920x1200@60"
  scale 1.5
  position x=0 y=0
}
```

Mirror mode: `Mod+Alt+Shift+Delete` or `omarchy niri monitor mirror`

### Window Rules

Window rules go in `~/.config/niri/system.kdl`. Niri KDL format:
```kdl
window-rule {
  match app-id="org.gnome.Calculator"
  open-floating true
  default-floating-size { width 400; height 500; }
}
```

Always validate after adding rules:
```bash
niri validate --config ~/.config/niri/config.kdl
```

### Fonts

```bash
omarchy font list
omarchy font current
omarchy font set <name>
```

### System

```bash
omarchy update                  # Full system update
omarchy version                 # Show version
omarchy debug --no-sudo --print # Debug info (ALWAYS use these flags)
omarchy system lock             # Lock screen
omarchy system shutdown         # Shutdown
omarchy system reboot           # Reboot
```

### Reminders

```bash
omarchy reminder 15 "Pickup Jack"
omarchy reminder 60 "Check laundry"
omarchy reminder show
omarchy reminder clear
```

## Troubleshooting

```bash
omarchy debug --no-sudo --print   # Debug info (always use these flags)
omarchy upload log                # Upload logs for support
omarchy refresh niri              # Reset niri configs to defaults
omarchy refresh <app>             # Reset any app config to defaults
omarchy reinstall                 # Nuclear option — full config reinstall
```

## Decision Framework

1. **Is it a stock omarchy command?** Use it directly
2. **Is it a config edit?** Edit in `~/.config/`, never `~/.local/share/omarchy/`
3. **Is it a theme customization?** Create a NEW custom theme directory
4. **Is it automation?** Use hooks in `~/.config/omarchy/hooks/`
5. **Is it a package install?** Use `omarchy pkg add <pkgs...>` (or `omarchy pkg aur add <pkgs...>` for AUR)
6. **Unsure if command exists?** Run `omarchy commands` first

## Out of Scope

This skill does NOT cover Omarchy source development. Do not use it for:
- Editing files in `~/.local/share/omarchy/`
- Creating or editing migrations
- Running `omarchy dev ...` commands

## Example Requests

- "Change my theme to catppuccin" → `omarchy theme set catppuccin`
- "Add a keybinding for Super+E to open file manager" → check conflicts, add to `~/.config/niri/bindings.kdl`, validate, reload
- "Configure my external monitor" → edit `~/.config/niri/monitors.kdl`, validate, reload
- "Make window gaps smaller" → edit `~/.config/niri/looknfeel.kdl`, validate, reload
- "Set up night light" → `omarchy toggle nightlight`
- "Set a reminder in 15 minutes" → `omarchy reminder 15 "message"`
- "Mirror my display" → `Mod+Alt+Shift+Delete` or `omarchy niri monitor mirror`
- "Reset waybar to defaults" → `omarchy refresh waybar`
- "Run a script every time I change themes" → create `~/.config/omarchy/hooks/theme-set`
