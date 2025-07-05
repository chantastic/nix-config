# Lesson 18: Zsh Functions, Evaluation Time, and Command Completion

## 1. Evaluation Time: Aliases vs. Functions

### Aliases
- **Definition:** Simple text substitutions, expanded by the shell before command execution.
- **Evaluation:** Aliases are expanded at parse time, not at execution time.
- **Limitation:** If you set `alias e="$EDITOR"`, it captures the value of `$EDITOR` at the time the alias is defined. If `$EDITOR` changes later, the alias does not update.
- **Use case:** Best for static, unchanging commands.

### Functions
- **Definition:** Shell functions are blocks of code executed when called.
- **Evaluation:** Functions are evaluated at execution time. If you define:
  ```zsh
  vi() { "$VISUAL" "$@"; }
  ```
  it will use the current value of `$VISUAL` every time you run `vi`.
- **Advantage:** Dynamic, always up-to-date with environment changes.
- **Use case:** Best for wrappers around commands that may change, or when you want to add logic.

#### **Trade-off Summary**
- Use **aliases** for static, simple substitutions.
- Use **functions** for dynamic, context-sensitive commands.

---

## 2. Repurposing Standard Commands: The `vi` Example

A powerful pattern is to override standard editor commands (like `vi`) with a shell function that launches the most modern installed editor, falling back as needed. For example:

```zsh
if command -v nvim >/dev/null 2>&1; then
  export VISUAL="nvim"
elif command -v vim >/dev/null 2>&1; then
  export VISUAL="vim"
else
  export VISUAL="vi"
fi

vi() {
  if [[ -z "$VISUAL" ]]; then
    echo "Error: $VISUAL is not set" >&2
    return 1
  fi
  "$VISUAL" "$@"
}
compdef _command vi
```

This means that running `vi` in your shell will always launch your preferred, most modern editor, but you can still access the system `vi` with `/usr/bin/vi` if needed.

### Trade-offs and Considerations
- **Pros:**
  - Always get your preferred editor, even when muscle memory types `vi`.
  - Consistent experience across systems.
- **Cons:**
  - You lose direct access to the system `vi` unless you use the full path.
  - May surprise collaborators or scripts expecting the original `vi` behavior in your interactive shell.
  - In rare recovery situations, you may need to bypass your function.

**Best Practice:**
- Document this override in your dotfiles for clarity.
- Only override commands you are sure you do not need in their original form interactively.

---

## 3. Command Completion with `compdef`

### What is `compdef`?
- `compdef` is a zsh builtin that associates a completion function with a command or function.
- Example: `compdef g=git` tells zsh to use git’s completions for your `g` function.

### Why is it needed?
- By default, zsh tries to guess completions for functions, but this is not always reliable, especially for custom wrappers.
- Explicitly setting `compdef` ensures your function gets the right completions, regardless of shell configuration or plugins.

### When should you use it?
- Whenever you create a function that wraps or mimics another command (e.g., `g` for `git`, `vi` for `$VISUAL`), add a `compdef` line to guarantee correct completions.

### Example:
```zsh
g() {
  if [[ $# -gt 0 ]]; then
    git "$@"
  else
    git status -sb
  fi
}
compdef g=git
```
This ensures `g` has the same completions as `git`.

---

## 4. Best Practices

- **For dynamic commands:** Use functions, not aliases.
- **For robust completions:** Use `compdef` to explicitly associate your function with the correct completion logic.
- **For maintainability:** Source your function files consistently (e.g., via a central loop in your shell config).
- **For overrides:** Clearly document any overrides of standard commands in your dotfiles.

---

## 5. Summary Table

| Approach   | Dynamic? | Supports Completion? | Best For                |
|------------|----------|---------------------|-------------------------|
| Alias      | No       | Sometimes           | Static commands         |
| Function   | Yes      | Yes (with compdef)  | Dynamic/wrapper commands|
| Function (override) | Yes | Yes (with compdef) | Repurposing standard commands |

---

## 6. Key Takeaways

- **Evaluation time matters:** Functions are evaluated when run, so they always use the latest environment.
- **Explicit is better:** Use `compdef` to ensure your custom functions get the right completions.
- **Consistency:** Source your shell customizations in a consistent, maintainable way.
- **Repurposing standard commands can be powerful,** but should be done thoughtfully and documented for clarity.
