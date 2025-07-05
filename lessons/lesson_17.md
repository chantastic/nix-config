# Lesson 17: Mastering $EDITOR and $VISUAL in Unix Shells

## Why Set $EDITOR and $VISUAL?

Many command-line tools (like `git`, `crontab`, `sudoedit`, etc.) use the `$EDITOR` and `$VISUAL` environment variables to determine which text editor to launch when you need to edit a file. Setting these variables ensures a consistent and comfortable editing experience across all your tools.

- **$EDITOR**: Used for terminal-based editing.
- **$VISUAL**: Used for graphical or more interactive editing (if supported).

## Best Practices

### 1. Set with Fallbacks
You can set these variables with fallback logic in your shell config (e.g., `.zshrc`, `.bashrc`) so that if your preferred editor isn't installed, another is used:

```sh
if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
elif command -v vim >/dev/null 2>&1; then
  export EDITOR="vim"
elif command -v nano >/dev/null 2>&1; then
  export EDITOR="nano"
else
  export EDITOR="vi"
fi

if command -v code >/dev/null 2>&1; then
  export VISUAL="code --wait"
elif command -v nvim >/dev/null 2>&1; then
  export VISUAL="nvim"
elif command -v vim >/dev/null 2>&1; then
  export VISUAL="vim"
else
  export VISUAL="vi"
fi
```

### 2. When to Set Both
- Most programs check `$VISUAL` first, then `$EDITOR`.
- If you want the same editor everywhere, set both to the same value.
- If you want a graphical editor for some tools and a terminal editor for others, set them differently.

### 3. Overriding for a Single Command
You can temporarily override these variables for a single command by prefixing the command:

```sh
VISUAL="code --wait" git commit
EDITOR="nano" crontab -e
```
This only affects the command you run, not your global settings.

## Summary Table

| Variable   | Checked First | Fallback      | Typical Use         |
|------------|---------------|---------------|---------------------|
| $VISUAL    | 1st           | $EDITOR       | Graphical editors   |
| $EDITOR    | 2nd           | System default| Terminal editors    |

## Key Takeaways
- Set `$EDITOR` and `$VISUAL` in your shell config for a consistent experience.
- Use fallback logic to ensure you always have a working editor.
- Override the editor for a single command by prefixing the command with the variable assignment.

---

**Example:**

```sh
VISUAL="code --wait" git commit
```

This opens your commit message in VS Code just for this command, even if your default is `nvim`.
