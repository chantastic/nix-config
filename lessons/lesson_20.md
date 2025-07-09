# Lesson 20: PHP and Laravel Development Setup

## Overview
Setting up PHP for Laravel development in Nix requires careful configuration of PHP extensions, package management, and development tools. This lesson covers creating a reproducible PHP development environment.

## The Problem
PHP applications, especially Laravel projects, require specific PHP extensions and tools. Common issues include:
- Missing PHP extensions (like `iconv`, `mbstring`)
- Symfony/Laravel installer errors
- Database connectivity issues
- Frontend tooling integration

## Solution: PHP Module (`modules/php.nix`)

### Complete PHP Module
```nix
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # PHP runtime with extensions needed for Laravel/Symfony
    (php83.withExtensions ({ enabled, all }: enabled ++ (with all; [
      mbstring
      iconv
      openssl
      pdo
      pdo_mysql
      pdo_sqlite
      bcmath
      ctype
      fileinfo
      tokenizer
      xml
      curl
      zip
      gd
      intl
    ])))
    php83Packages.composer
    
    # Database tools commonly used with Laravel
    sqlite
    redis
    
    # Laravel development tools
    nodejs_22    # Required for Laravel Mix/Vite
    pnpm         # Package manager for frontend assets
    
    # Laravel installer as a shell script
    (pkgs.writeShellScriptBin "laravel" ''
      exec ${php83Packages.composer}/bin/composer create-project laravel/laravel "$@"
    '')
  ];

  # Set up environment variables for PHP development
  home.sessionVariables = {
    PHP_INI_SCAN_DIR = "$HOME/.config/php/conf.d";
    COMPOSER_HOME = "$HOME/.config/composer";
    COMPOSER_GLOBAL_DIR = "$HOME/.config/composer/vendor/bin";
  };

  # Add Composer global bin to PATH
  home.sessionPath = [
    "$HOME/.config/composer/vendor/bin"
  ];

  # Create necessary directories for PHP development
  home.activation = {
    setupPhpDevelopment = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Create PHP config directory
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG $HOME/.config/php/conf.d
      
      # Create Composer directories for global packages
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG $HOME/.config/composer
    '';
  };
}
```

### Key Components Explained

#### 1. PHP with Extensions
```nix
(php83.withExtensions ({ enabled, all }: enabled ++ (with all; [
  mbstring    # Multi-byte string support
  iconv       # Character encoding conversion
  openssl     # SSL/TLS support
  pdo         # Database abstraction layer
  pdo_mysql   # MySQL database support
  pdo_sqlite  # SQLite database support
  bcmath      # Arbitrary precision mathematics
  ctype       # Character type checking
  fileinfo    # File information
  tokenizer   # PHP tokenizer
  xml         # XML parsing
  curl        # HTTP client
  zip         # Archive support
  gd          # Image processing
  intl        # Internationalization
])))
```

#### 2. Development Tools
- **Composer**: PHP package manager
- **Laravel installer**: Custom script using `composer create-project`
- **Node.js & pnpm**: Frontend tooling for Laravel Mix/Vite
- **Database tools**: SQLite and Redis

#### 3. Environment Configuration
- `PHP_INI_SCAN_DIR`: Custom PHP configuration directory
- `COMPOSER_HOME`: Composer configuration directory
- PATH setup for global Composer packages

## Integration with Flake

Add the PHP module to your `flake.nix`:

```nix
homeConfigurations.chan = home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    # ... other modules
    ./modules/php.nix
  ];
};
```

## Common Issues and Solutions

### 1. Symfony Polyfill Error
**Problem**: `Call to undefined function Symfony\Polyfill\Mbstring\iconv()`

**Solution**: Ensure `iconv` and `mbstring` extensions are included in the PHP configuration.

### 2. Laravel Installer Not Found
**Problem**: `laravel` command not found after activation

**Solution**: 
- Restart your shell: `exec $SHELL`
- Or use the full path: `~/.config/composer/vendor/bin/laravel`

### 3. Database Connection Issues
**Problem**: Cannot connect to MySQL/SQLite

**Solution**: The module includes `pdo_mysql` and `pdo_sqlite` extensions, plus database tools.

## Usage

### Activating the Configuration
```bash
nix run .#activate
```

### Creating a Laravel Project
```bash
# Using the custom Laravel installer
laravel my-project

# Or using Composer directly
composer create-project laravel/laravel my-project
```

### Verifying PHP Extensions
```bash
php -m | grep -E "(iconv|mbstring|pdo)"
```

## Best Practices

1. **Reproducible Setup**: Use Nix packages instead of manual installations
2. **Environment Variables**: Configure through home-manager, not shell scripts
3. **Version Consistency**: Pin PHP and package versions
4. **Extension Management**: Include all necessary extensions upfront

## Development Workflow

1. **Project Creation**: Use `laravel new-project` or `composer create-project`
2. **Database Setup**: SQLite is included by default, MySQL available
3. **Frontend Assets**: Node.js and pnpm are included for asset compilation
4. **Testing**: PHPUnit and Laravel testing tools are available

## Summary

This PHP module provides a complete Laravel development environment with:
- ✅ PHP 8.3 with all necessary extensions
- ✅ Composer for package management
- ✅ Laravel installer for project creation
- ✅ Database tools (SQLite, Redis)
- ✅ Frontend tooling (Node.js, pnpm)
- ✅ Proper environment configuration
- ✅ Reproducible setup through Nix

The configuration eliminates common PHP setup issues and provides a consistent development environment across different machines.
