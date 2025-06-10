{ self, pkgs, pkgs-unstable, config, system, username, ...}:
let
  
in
{
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    nh              # Nix helper
    nix-tree        # Interactively browse a Nix store paths dependencies

    git
    lazygit

    # # Tools for the terminal
    tmux
    mkalias         # Quick'n'dirty tool to make APFS aliases
    lf              # Terminal file manager written in Go and heavily inspired by ranger
    zoxide          # Fast cd command that learns your habits
    bat
    btop            # Monitor of resources
    eza             # Modern, maintained replacement for ls
    powerline       # Ultimate statusline/prompt utility -> required by tmux
    atuin           # Replacement for a shell history
    ripgrep
    gopass
    wget
    pwgen
    httpie
    jless           # Command-line pager for JSON data
    fd              # Required for Nvim Telescope plugin for repository search

    gnupg           # Modern release of the GNU Privacy Guard, a GPL OpenPGP implementation
    pinentry-curses # Gnu implementation for entering PINs or passphrases in a terminal

    # My editor for everythin
    python312
    pkgs-unstable.neovim
    luarocks        # A package manager for Lua modules.

    # Development environment
    nodejs          # Event-driven I/O framework for the V8 JavaScript engine
    vscode
    yarn            # Fast, reliable, and secure dependency management for nodejs
    npkill          # Easily find and remove old and heavy node_modules folders

    go

    # Instrastructure as code
    ansible
    terraform
    coreutils-prefixed # GNU Core Utilities Prefixed  (Required for Ansible)

    # Tools for Kubernetes
    kubectl
    kubectx         # Fast way to switch between clusters and namespaces in kubectl!
    stern
    k9s             # Kubernetes CLI To Manage Your Clusters In Style

    # Password management
    _1password-cli  # 1Password command-line utility
    keepassxc   # Offline password manager with many features
    # pam-reattach    # Reattach to the user's GUI session on macOS during authentication (for Touch ID support in tmux)

    raycast         # Control your tools with a few keystrokes
    obsidian        # Powerful knowledge base that works on top of a local folder of plain text Markdown files

    pipx            # Install and run Python applications in isolated environments

    # # code-cursor     # AI-powered code editor built on vscode
    tgpt        # AI from the command line
  ];

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    # nerd-fonts.fira-code
  ];

  users.users."${username}" = {
    name = "${username}";
    home = "/Users/${username}";
  };
   
  # This is using homebrew to install packages which Nix doesn't have
  homebrew = {
    enable = true;

    onActivation.cleanup = "zap";         # make sure that only packages from here are installed
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

    brews = [
      "mas"                               # Required for searching for app-ids in the MacOS app-store
      "theseal/ssh-askpass/ssh-askpass"
      "michaelroosz/ssh/libsk-libfido2"   # Fixes a problem with Yubikeys
      "michaelroosz/ssh/sshpass"          # Contains an important fix for keeping connections open also when using ssh-jumphost 
      # "node@20"
    ];
    casks = [
      "font-comic-shanns-mono-nerd-font"
      "chromium"
      "firefox"
      # "keychain" # User-friendly front-end to ssh-agent
      "1password"
      # "1password_cli"
      "yubico-authenticator"
      "yubico-yubikey-manager"
      "ghostty"
      "studio-3t"
      "orbstack"        # Running Docker containers
    ];
    taps = [
      "theseal/ssh-askpass"
      "michaelroosz/ssh"
    ];

    # Define apps from the MacOS app-store here - Login is required
    # Search for the app id with `mas search Wireguard`
    masApps = {
      "Wireguard" = 1451685025;
    };
  };

  system.activationScripts.applications.text = let
    env = pkgs.buildEnv {
      name = "system-applications";
      paths = config.environment.systemPackages;
      pathsToLink = "/Applications";
    };
  in
    pkgs.lib.mkForce ''
      # Set up applications.
      echo "setting up /Applications..." >&2
      rm -rf /Applications/Nix\ Apps
      mkdir -p /Applications/Nix\ Apps
      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      while read -r src; do
        app_name=$(basename "$src")
        echo "copying $src" >&2
        ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      done
    '';     
   
  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # Automatic updating
  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.dates = "weekly";

  # Automatic cleanup
  # nix.gc.automatic = true;
  # nix.gc.interval = "daily";
  # nix.gc.options = "--delete-older-than 10d";
  # nix.optimise.automatic = true;

  # security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    NSGlobalDomain.AppleICUForce24HourTime = true;
    NSGlobalDomain.AppleShowAllFiles = true;
    loginwindow.LoginwindowText = "MacBook Pro - Jan Baer";
    loginwindow.GuestEnabled = false;
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 10;
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = system;
}
