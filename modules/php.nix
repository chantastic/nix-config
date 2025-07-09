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