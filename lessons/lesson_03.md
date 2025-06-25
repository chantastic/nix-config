# Lesson 3: Git Configuration with Home-Manager

## What We Learned

In this lesson, we explored how to configure Git declaratively using home-manager, learning the difference between first-class validated options and flexible extraConfig settings. We converted an existing git configuration file into a declarative, version-controlled setup.

### Key Concepts Covered

1. **First-Class Options**: Type-validated configuration options provided by home-manager
2. **ExtraConfig**: Flexible configuration for settings without built-in validation
3. **Object Syntax**: Organizing related settings into nested objects for better readability
4. **Configuration Migration**: Converting existing dotfiles to declarative configuration
5. **Git LFS Integration**: Managing complex git configurations including filters

### Our Final Git Configuration

```nix
programs.git = {
  enable = true;
  
  # First-class validated options
  userName = "Michael Chan";
  userEmail = "mijoch@gmail.com";
  
  # Flexible extraConfig for all other settings
  extraConfig = {
    core.editor = "nvim";
    credential.helper = "osxkeychain";
    diff = {
      compactionHeuristic = true;
      colorMoved = "zebra";
    };
    fetch.prune = true;
    format.pretty = "oneline";
    help.autocorrect = 1;
    init.defaultBranch = "main";
    log = {
      abbrevCommit = true;
      date = "relative";
      decorate = "short";
      pretty = "oneline";
    };
    pull.rebase = true;
    push = {
      autoSetupRemote = true;
      followTags = true;
      default = "current";
    };
    rebase.autosquash = true;
    ui.color = true;
    "filter \"lfs\"" = {
      clean = "git-lfs clean -- %f";
      smudge = "git-lfs smudge -- %f";
      process = "git-lfs filter-process";
      required = true;
    };
  };
  
  # Aliases using first-class option
  aliases = {
    a = "add";
    b = "branch";
    c = "commit";
    d = "diff";
    e = "reset";
    f = "fetch";
    g = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset'";
    h = "cherry-pick";
    i = "init";
    l = "pull";
    m = "merge";
    n = "config";
    o = "checkout";
    p = "push";
    r = "rebase";
    s = "status";
    t = "tag";
    u = "prune";
    w = "switch";
    branches = "for-each-ref --sort=-committerdate --format='\"%(color:blue)%(authordate:relative)\t%(color:red)%(authorname)\t%(color:white)%(color:bold)%(refname:short)\"' refs/remotes";
  };
};
```

## Step-by-Step Configuration

### Step 1: Enable Git Program

Start by enabling the git program module:

```nix
programs.git = {
  enable = true;
  # ... configuration here
};
```

**Key Point**: The `enable = true` tells home-manager to manage git configuration for you.

### Step 2: Use First-Class Options

For settings that have type validation, use the built-in options:

```nix
userName = "Michael Chan";
userEmail = "mijoch@gmail.com";
aliases = {
  s = "status";
  c = "commit";
  # ... more aliases
};
```

**Advantages**:
- Type checking prevents invalid values
- Better IDE support with autocomplete
- Clear documentation of available options
- Automatic validation at build time

### Step 3: Configure with ExtraConfig

For settings without first-class options, use `extraConfig`:

```nix
extraConfig = {
  core.editor = "nvim";
  init.defaultBranch = "main";
  credential.helper = "osxkeychain";
  # ... more settings
};
```

**When to Use ExtraConfig**:
- Settings not covered by first-class options
- Custom git configurations
- Complex nested structures (like git LFS filters)
- Experimental or new git features

### Step 4: Organize with Object Syntax

Group related settings into objects for better organization:

```nix
extraConfig = {
  diff = {
    compactionHeuristic = true;
    colorMoved = "zebra";
  };
  log = {
    pretty = "oneline";
    abbrevCommit = true;
    decorate = "short";
    date = "relative";
  };
  push = {
    default = "current";
    followTags = true;
    autoSetupRemote = true;
  };
};
```

**Benefits**:
- Better readability and organization
- Easier maintenance and updates
- Clearer intent and structure
- Mirrors git config file organization

### Step 5: Apply the Configuration

To apply your git configuration changes to your environment:

```bash
# Build and activate the home-manager configuration
nix run .#homeConfigurations.chan.activationPackage
```

**What This Does**:
- Builds your home-manager configuration
- Generates the git config file at `~/.config/git/config`
- Applies all your git settings

**Verification**:
```bash
# Check that your git configuration is active
git config --list --show-origin

# Test a specific setting
git config user.name
git config user.email
```

**Note**: You only need to run this command when you make changes to your `flake.nix`. The configuration persists until you update it again.

## First-Class Options vs ExtraConfig

### First-Class Options (Recommended When Available)

**What They Are**: Built-in, type-validated configuration options provided by home-manager.

**Examples**:
```nix
programs.git = {
  enable = true;
  userName = "Your Name";           // ✅ Type validated
  userEmail = "email@example.com";  // ✅ Type validated
  aliases = {                       // ✅ Type validated
    s = "status";
    c = "commit";
  };
  delta = {                         // ✅ Type validated
    enable = true;
    options = {
      line-numbers = true;
      side-by-side = true;
    };
  };
};
```

**Advantages**:
- **Type Safety**: Invalid values caught at build time
- **IDE Support**: Autocomplete and documentation
- **Validation**: Automatic checking of configuration
- **Maintainability**: Clear interface and expectations

### ExtraConfig (Flexible Configuration)

**What It Is**: A flexible way to set any git configuration value.

**Examples**:
```nix
extraConfig = {
  core.editor = "nvim";
  init.defaultBranch = "main";
  "filter \"lfs\"" = {
    clean = "git-lfs clean -- %f";
    smudge = "git-lfs smudge -- %f";
  };
  alias.custom = "complex command with spaces";
};
```

**When to Use**:
- Settings without first-class options
- Custom or experimental git features
- Complex nested configurations
- Platform-specific settings

**Advantages**:
- **Flexibility**: Can configure any git setting
- **Completeness**: No limitations on what can be set
- **Compatibility**: Works with any git version or feature

## Nice to Know

### Configuration Precedence

**How It Works**: Home-manager generates a git config file that git reads. The order of precedence is:

1. Command line options (`git -c key=value`)
2. Environment variables (`GIT_CONFIG_KEY=value`)
3. Repository-specific config (`.git/config`)
4. User config (`~/.gitconfig` or `~/.config/git/config`)
5. System config (`/etc/gitconfig`)

**Home-Manager's Role**: Home-manager manages the user config file, so it takes precedence over system config but can be overridden by repository-specific settings.

### Git Config File Location

**Default Location**: `~/.config/git/config` (XDG Base Directory specification)

**Home-Manager Behavior**: Home-manager creates this file automatically when you enable the git program.

**Manual Override**: You can still manually edit this file, but changes will be overwritten when you run home-manager activation.

### Configuration Validation

**Build-Time Checking**: Home-manager validates your configuration when you build the flake:

```bash
nix build .#homeConfigurations.chan.activationPackage
```

**Common Errors**:
- Invalid boolean values (use `true`/`false`, not `"true"`/`"false"`)
- Missing quotes around strings with spaces
- Incorrect nesting in object syntax

### Git LFS Integration

**Complex Configuration**: Git LFS requires a special filter configuration that demonstrates the power of extraConfig:

```nix
"filter \"lfs\"" = {
  clean = "git-lfs clean -- %f";
  smudge = "git-lfs smudge -- %f";
  process = "git-lfs filter-process";
  required = true;
};
```

**Key Points**:
- The section name includes quotes: `"filter \"lfs\""`
- This creates a `[filter "lfs"]` section in the git config
- The `required = true` ensures LFS is enforced

### Alias Best Practices

**Simple Aliases**: Use the first-class `aliases` option for simple command shortcuts:

```nix
aliases = {
  s = "status";
  c = "commit";
  co = "checkout";
};
```

**Complex Aliases**: For complex commands with formatting, use extraConfig:

```nix
extraConfig = {
  alias.graph = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset'";
  alias.branches = "for-each-ref --sort=-committerdate --format='\"%(color:blue)%(authordate:relative)\t%(color:red)%(authorname)\t%(color:white)%(color:bold)%(refname:short)\"' refs/remotes";
};
```

## Jumping Off Points

### Advanced Git Configuration

**Explore These Areas**:
- **Git Hooks**: Set up pre-commit, post-commit, and other hooks
- **Git Attributes**: Configure file-specific behaviors
- **Git Ignore**: Manage global ignore patterns
- **Git Templates**: Set up commit message templates

**Example - Git Hooks**:
```nix
extraConfig = {
  core.hooksPath = "~/.config/git/hooks";
};
```

### Integration with Other Tools

**Development Tools**:
- **Delta**: Enhanced diff viewer
- **Lazygit**: Terminal UI for git
- **GitHub CLI**: GitHub integration
- **Git Credential Manager**: Enhanced credential handling

**Example - Delta Integration**:
```nix
programs.git = {
  enable = true;
  delta = {
    enable = true;
    options = {
      line-numbers = true;
      side-by-side = true;
      navigate = true;
    };
  };
};
```

### Multi-Environment Configuration

**Different Settings for Different Contexts**:
- Work vs personal git configurations
- Different email addresses for different projects
- Environment-specific aliases

**Example - Conditional Configuration**:
```nix
programs.git = {
  enable = true;
  userName = "Michael Chan";
  userEmail = if isWorkMachine then "michael.chan@company.com" else "mijoch@gmail.com";
  extraConfig = {
    # Work-specific settings
    url."git@github.com:company/".insteadOf = "https://github.com/company/";
  };
};
```

### Custom Git Commands

**Create Your Own Git Subcommands**:
- Custom scripts for common workflows
- Project-specific git operations
- Integration with other development tools

**Example - Custom Script**:
```nix
home.packages = with pkgs; [
  (pkgs.writeScriptBin "git-sync" ''
    #!/bin/bash
    git fetch --all
    git pull --rebase
    git push
  '')
];
```

### Git Configuration Modules

**Reusable Configuration Components**:
- Create modules for common git setups
- Share configurations across projects
- Maintain consistent git practices

**Example - Development Module**:
```nix
# modules/git-development.nix
{ config, lib, ... }:
{
  programs.git = {
    enable = true;
    extraConfig = {
      pull.rebase = true;
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
    };
    aliases = {
      sync = "pull --rebase && push";
      amend = "commit --amend --no-edit";
    };
  };
}
```

### Git Workflow Automation

**Streamline Common Tasks**:
- Automated branch management
- Commit message templates
- Code review workflows
- Release management

**Example - Branch Management**:
```nix
extraConfig = {
  alias.new-feature = "!f() { git checkout -b feature/$1; }; f";
  alias.finish-feature = "!f() { git checkout main && git pull && git branch -d feature/$1; }; f";
};
```

## Challenges

### Challenge 1: Multi-Repository Workflow
**Goal**: Set up git configuration for working with multiple repositories

**Tasks**:
- Configure different remotes for different projects
- Set up repository-specific gitignore patterns
- Create aliases for common multi-repo operations

**Learning**: Git configuration scoping and workflow automation

### Challenge 2: Git Hooks Integration
**Goal**: Set up automated git hooks for code quality

**Tasks**:
- Install and configure pre-commit hooks
- Set up linting and formatting checks
- Configure post-commit notifications

**Learning**: Git hook management and development workflow integration

### Challenge 3: Advanced Git Tools
**Goal**: Integrate enhanced git tools into your workflow

**Tasks**:
- Set up delta for better diffs
- Configure lazygit for terminal UI
- Integrate GitHub CLI for enhanced GitHub workflow

**Learning**: Tool integration and enhanced git experience

### Challenge 4: Conditional Configuration
**Goal**: Create environment-specific git configurations

**Tasks**:
- Different settings for work vs personal projects
- Machine-specific configurations
- Project-specific git aliases and settings

**Learning**: Configuration management and environment-specific setups

## Next Lessons Preview

### Lesson 4: Shell Configuration with Home-Manager
- Configuring zsh/bash through home-manager
- Environment variables and PATH management
- Shell aliases and functions
- Integration with git and other tools

### Lesson 5: Development Environment Setup
- Language-specific tool configurations
- IDE and editor setup
- Development workflow automation
- Project-specific development shells

### Lesson 6: Advanced Home-Manager Features
- Custom modules and configuration reuse
- Conditional configurations
- Integration with external services
- Performance optimization

## Key Takeaways

1. **First-Class vs ExtraConfig**: Use validated options when available, extraConfig for flexibility
2. **Object Syntax**: Group related settings for better organization and readability
3. **Configuration Migration**: Convert existing dotfiles to declarative configuration
4. **Type Safety**: Leverage home-manager's validation for error prevention
5. **Workflow Integration**: Git configuration is part of a larger development environment

## Reflection Questions

- How does declarative git configuration change your approach to setting up new development environments?
- What advantages do you see in having your git configuration version-controlled?
- How might this approach help with team consistency and onboarding?
- What other configuration files in your development environment could benefit from this approach?

## Troubleshooting Common Issues

### "Invalid configuration" errors
**Cause**: Type validation failures in first-class options
**Solution**: Check the home-manager documentation for correct value types

### Configuration not taking effect
**Cause**: Home-manager configuration not activated
**Solution**: Run `nix run .#homeConfigurations.chan.activationPackage`

### Git aliases not working
**Cause**: Complex aliases need to be in extraConfig, not the aliases option
**Solution**: Move complex commands to `extraConfig.alias.*`

### LFS configuration issues
**Cause**: Incorrect filter section syntax
**Solution**: Ensure proper quoting: `"filter \"lfs\""` not `filter.lfs`

This lesson establishes the foundation for managing complex application configurations declaratively, setting you up for more advanced home-manager usage!
