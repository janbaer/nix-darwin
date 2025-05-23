{
  description = "Jan's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nix-homebrew }:
  let
    username = "jan.baer";
    configuration = { pkgs, config, ... }: {
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";


      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        git
        lazygit
        mkalias         # Quick'n'dirty tool to make APFS aliases
        go
        neovim
        tmux
        utm             # Full featured system emulator and virtual machine host for iOS and macOS
        lf              # Terminal file manager written in Go and heavily inspired by ranger
        bat
        btop            # Monitor of resources
        eza             # Modern, maintained replacement for ls
        powerline       # Ultimate statusline/prompt utility -> required by tmux
        atuin           # Replacement for a shell history
        ripgrep
        gopass
        ansible
        terraform
        vscode
        luarocks        # A package manager for Lua modules.
        nodejs_20       # Event-driven I/O framework for the V8 JavaScript engine
        yarn            # Fast, reliable, and secure dependency management for nodejs
        npkill          # Easily find and remove old and heavy node_modules folders
        kubectl
        kubectx         # Fast way to switch between clusters and namespaces in kubectl!
        stern
        k9s             # Kubernetes CLI To Manage Your Clusters In Style
        wget
        coreutils-prefixed # GNU Core Utilities Prefixed
        _1password-cli  # 1Password command-line utility
        # pam-reattach    # Reattach to the user's GUI session on macOS during authentication (for Touch ID support in tmux)
        raycast         # Control your tools with a few keystrokes
        zoxide          # Fast cd command that learns your habits
        obsidian        # Powerful knowledge base that works on top of a local folder of plain text Markdown files
        television      # Blazingly fast general purpose fuzzy finder TUI
        pipx            # Install and run Python applications in isolated environments
        nh              # Nix helper

        python312

        code-cursor     # AI-powered code editor built on vscode

        lima            # Linux virtual machines
      ];

      fonts.packages = with pkgs; [
        fira-code
        fira-code-symbols
        nerd-fonts.fira-code
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
        ];
        casks = [
          "font-comic-shanns-mono-nerd-font"
          "chromium"
          "firefox"
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
      system.stateVersion = 6;

      # Automatic updating
      # system.autoUpgrade.enable = true;
      # system.autoUpgrade.dates = "weekly";

      # Automatic cleanup
      # nix.gc.automatic = true;
      # nix.gc.interval = "daily";
      # nix.gc.options = "--delete-older-than 10d";
      # nix.optimise.automatic = true;

      security.pam.services.sudo_local.touchIdAuth = true;

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
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#M9WMQ6QPM7
    darwinConfigurations."M9WMQ6QPM7" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration

        home-manager.darwinModules.home-manager
        {
          # `home-manager` config
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${username}" = import ./home.nix;
        }

        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = username;
            autoMigrate = true;
          };
        }
      ];
    };
  };
}
