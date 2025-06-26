# Lesson 7: Managing macOS Settings Declaratively with Nix Flakes

## What We Tried

Initially, we attempted to manage macOS system preferences (such as Finder, Dock, and keyboard settings) using Home Manager's `home.activation` scripts. The goal was to have all our user and system preferences managed declaratively in Nix, just like our dotfiles and packages.

## The Challenge: Permissions and Environment

While Home Manager is excellent for user-level configuration, it runs its activation scripts in a non-interactive environment. This led to two main issues:

- **Permissions**: Some `defaults write` commands require the user's full environment and may not work as expected in Home Manager's activation context.
- **No Feedback**: The activation process gave no errors, but many settings were not actually applied. Manual checks showed that only some settings (like Finder view style) took effect, while others (like Dock autohide) did not.

## The Solution: Flake App with a Script

To reliably apply macOS system preferences, we moved the settings into a standalone shell script (`scripts/macos-settings.sh`). We then exposed this script as a flake app in `flake.nix`:

```nix
apps.${system} = {
  macos-settings = {
    type = "app";
    program = toString (pkgs.writeShellScript "macos-settings" (builtins.readFile ./scripts/macos-settings.sh));
  };
};
```

This lets us run all our macOS settings with:

```sh
nix run .#macos-settings
```

## Why This Works

- **Runs in Your User Shell**: The script is executed in your normal shell environment, so it has the right permissions and context to change system preferences.
- **Separation of Concerns**: User environment (dotfiles, packages) is managed by Home Manager; system preferences are managed by a script.
- **Reproducibility**: The script is version-controlled and declarative, so you can re-apply or tweak settings at any time.
- **Debuggability**: You get immediate feedback if a command fails.

## Key Takeaways

- Home Manager is best for user-level configuration, not system-level macOS preferences.
- For system preferences, use a script and expose it as a flake app for reproducibility and convenience.
- Always verify that your settings are actually applied (e.g., with `defaults read`).

## Next Steps

- You can extend this pattern for other system-level scripts (e.g., sidebar configuration, custom automation).
- Keep your scripts in the `scripts/` folder and reference them from your flake for a clean, maintainable setup.
