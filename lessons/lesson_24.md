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


