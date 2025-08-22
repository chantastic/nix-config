# Adding custom fonts to nix setup
_Exported on 8/21/2025 at 17:16:18 PDT from Cursor (1.4.5)_

---

**User**

i'd like to add custom fonts to my nix setup

---

**Cursor**

I'll help you add custom fonts to your Nix setup. Let me first examine your current configuration to understand how it's structured.


Now let me check if there are any existing font configurations in the modules:


I don't see a dedicated font module. Let me check one of the existing modules to understand the pattern:


Perfect. Now I'll create a fonts module for you. There are two main approaches for custom fonts in Nix:

1. **System fonts** - Install fonts system-wide via `fonts.fonts`
2. **Home Manager fonts** - Install fonts for your user via `home.packages`

I'll create a module that supports both approaches:


```plaintext
{ config, lib, pkgs, ... }:

let
  # Define your custom fonts here
  customFonts = with pkgs; [
    # Add your custom font packages here
    # Example: jetbrains-mono
    # Example: fira-code
    # Example: source-code-pro
  ];

  # For system-wide fonts (requires sudo)
  systemFonts = with pkgs; [
    # Add system fonts here
    # Example: noto-fonts
    # Example: liberation-fonts
  ];

in {
  # User-specific fonts (installed to ~/.nix-profile/share/fonts)
  home.packages = customFonts;

  # System-wide fonts (requires sudo nixos-rebuild)
  # Uncomment if you want system fonts
  # fonts.fonts = systemFonts;

  # Font configuration for applications
  fonts.fontconfig = {
    enable = true;
    # Enable subpixel rendering for better font rendering
    subpixel = {
      rgba = "rgb";
      lcdfilter = "default";
    };
    # Enable antialiasing
    antialias = true;
    # Enable hinting
    hinting = {
      enable = true;
      style = "slight";
    };
  };
}
```

Now I need to add this fonts module to your flake.nix:


```plaintext
          ./modules/git.nix
          ./modules/node.nix
          ./modules/shell.nix
          ./modules/media.nix
          ./modules/python.nix
          ./modules/php.nix
          ./modules/neovim.nix

->

          ./modules/git.nix
          ./modules/node.nix
          ./modules/shell.nix
          ./modules/media.nix
          ./modules/python.nix
          ./modules/php.nix
          ./modules/neovim.nix
          ./modules/fonts.nix
```

**Done.** I've created a fonts module for your Nix setup.

## What I added:

- **`modules/fonts.nix`** - Font configuration module
- **Updated `flake.nix`** - Added the fonts module to your home configuration

## How to use it:

1. **Edit `modules/fonts.nix`** - Add your desired fonts to the `customFonts` list
2. **Run `nix run .#activate`** - Apply the changes

## Popular font options:

```nix
customFonts = with pkgs; [
  jetbrains-mono      # Programming font
  fira-code           # Programming font with ligatures
  source-code-pro     # Adobe's programming font
  inter               # Modern UI font
  roboto              # Google's system font
  noto-fonts         # Google's universal font family
];
```

The module includes fontconfig settings for better rendering (antialiasing, hinting, subpixel rendering).

```plaintext
customFonts = with pkgs; [
  jetbrains-mono      # Programming font
  fira-code           # Programming font with ligatures
  source-code-pro     # Adobe's programming font
  inter               # Modern UI font
  roboto              # Google's system font
  noto-fonts         # Google's universal font family
];
```

---

**User**

can you tell me a little about system wide fonts vs user fonts?

for the most part, i see this machine as a single use machine. so i'm ok with just the home-manager option

---

**Cursor**

**System-wide vs User fonts:**

## System-wide fonts (`fonts.fonts`)
- Installed to `/run/current-system/sw/share/fonts`
- Available to **all users** on the system
- Requires `sudo nixos-rebuild switch` (or equivalent)
- Persists across reboots
- Good for shared machines, servers, or when you want fonts available system-wide

## User fonts (`home.packages`)
- Installed to `~/.nix-profile/share/fonts`
- Available to **your user only**
- Applied via `home-manager switch` (no sudo needed)
- Also persists across reboots
- Perfect for single-user machines

## For your use case:
Since this is a single-user machine, **user fonts are ideal**. They're:
- Simpler to manage (no sudo required)
- Faster to apply changes
- Cleaner separation of concerns

## Current setup:
Your `modules/fonts.nix` is already configured for user fonts via `home.packages = customFonts`. The system fonts section is commented out.

**Just add fonts to the `customFonts` list and run `nix run .#activate`** - that's it.

The fontconfig settings will work with either approach, so you get the same rendering quality regardless.

---

**User**

add /lessons/lesson_24.md lesson.
 based on what we learned here.

---

**Cursor**

I'll create a todo list, add `lessons/lesson_24.md` with a concise guide about user vs system fonts and home-manager usage, and then mark the todos complete.

I'll mark the todo as in_progress, create `lessons/lesson_24.md`, run lints on it, then mark todos complete.

```markdown
# Lesson 24: Managing Fonts with Nix and Home Manager

This lesson explains the difference between system-wide fonts and user-specific fonts, and shows a minimal, practical workflow for adding custom fonts to your Home Manager configuration.

## Key concepts

- **System-wide fonts**: installed at the system level and available to all users. On NixOS this typically means adding font packages to `fonts.fonts` and rebuilding the system. Requires elevated privileges and is suited for multi-user machines or when you manage a fleet of machines.

- **User (Home Manager) fonts**: installed into your user profile (e.g. `~/.nix-profile/share/fonts`) and managed by Home Manager via `home.packages`. No sudo required, faster iteration, and ideal for single-user machines.

## Why prefer Home Manager for single-user machines

- No root required — use `home-manager switch` or `nix run .#activate` to apply changes.
- Easier to test and iterate: add/remove fonts and re-run the activation command.
- Keeps your machine configuration portable and per-user.

## Minimal example

Add a module `modules/fonts.nix` (already included in the repo) and add fonts to `customFonts`:

```nix
customFonts = with pkgs; [
  jetbrains-mono
  fira-code
  inter
];

home.packages = customFonts;
```

Then run:

```bash
# activate the flake's home-manager config
nix run .#activate
```

Fonts will be installed to your user profile and available to GUI and terminal applications after re-login or after refreshing your desktop session.

## Font rendering options

The fonts module includes `fontconfig` settings (antialias, hinting, subpixel) to improve rendering. These settings apply regardless of using system or user fonts.

## Troubleshooting

- If an application doesn't see a newly installed font, log out and log back in or restart the app.
- Use `fc-list | rg <font-name>` to verify the font is installed and visible to fontconfig.
- On macOS, GUI apps may need a full restart to pick up new fonts.

## Takeaway

For personal machines, prefer Home Manager (`home.packages`) for font management — it's simpler, reversible, and doesn't require root.


```

Done — I created `lessons/lesson_24.md` explaining user vs system fonts and how to use Home Manager. 

- Edits: added `modules/fonts.nix` earlier and `lessons/lesson_24.md` now.
- To install fonts: add packages to `customFonts` in `modules/fonts.nix` and run `nix run .#activate`.
- All todos completed.

