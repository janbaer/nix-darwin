{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  username = "jan.baer";
in {
  home.stateVersion = "24.11";

  home.username = "${username}";
  home.homeDirectory = "/Users/${username}";

  xdg.enable = true;

  home.packages = with pkgs; [
    # devenv      # Fast, Declarative, Reproducible, and Composable Developer Environments

    lima          # Run Linux containers in Docker

    # Ansible related tools
    molecule      # Testing of Ansible roles
    ansible-lint  # Linter for Ansible
    yamllint      # Linter for YAML files

    uv            # Extremely fast Python package installer and resolver, written in Rust
    volta         # Node Version Manager
  ];

  programs = {
    git = import ./programs/git.nix {inherit config pkgs;};
    tmux = import ./programs/tmux.nix {inherit pkgs;};
    zsh = import ./programs/zsh.nix {inherit config pkgs lib; };
    zoxide = (import ./programs/zoxide.nix { inherit config pkgs; });
    fzf = import ./programs/fzf.nix {inherit pkgs;};
    # direnv = import ./programs/direnv.nix {inherit pkgs;};
  };


  home.sessionVariables = {
    SSH_SK_PROVIDER = "/usr/local/lib/libsk-libfido2.dylib";
    SSH_ASKPASS = "/opt/homebrew/bin/ssh-askpass";
    SSH_AUTH_SOCK_LOCAL = "/private/tmp/com.apple.launchd.2kMRnNrA1N/Listeners";
    SSH_AUTH_SOCK = "/private/tmp/com.apple.launchd.p1DRKW2MxY/Listeners";
    VOLTA_HOME = "$HOME/.volta";
  };

  home.file = {
    ".tmux" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.tmux";
      force = true;
      recursive = true;
    };
    ".tmux.conf" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.tmux.conf";
      force = true;
    };
    ".gitattributes" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.gitattributes";
      force = true;
    };
    ".gitconfig" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.gitconfig";
      force = true;
    };
    ".gitconfig_check24" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.gitconfig_check24";
      force = true;
    };
    ".config/zsh" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/zsh";
      force = true;
      recursive = true;
    };
    ".zshenv" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.zshenv";
      force = true;
    };
    ".config/lf" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/lf";
      force = true;
      recursive = true;
    };
    ".config/lazygit" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/lazygit";
      force = true;
      recursive = true;
    };
    ".config/nvim" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/nvim";
      force = true;
      recursive = true;
    };
    ".config/Code" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/Code";
      force = true;
      recursive = true;
    };
    ".config/powerline" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/powerline";
      force = true;
    };
    ".config/atuin" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/atuin";
      force = true;
      recursive = true;
    };
    ".config/ghostty" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/ghostty"; 
      force = true;
    };
    ".config/mcphub/servers.json" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/mcphub/servers.json";
      force = true;
    };
    ".fzf-init.zsh" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.fzf-init.zsh";
      force = true;
    };
    ".p10k.zsh" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.p10k.zsh";
      force = true;
    };
    "bin/init-keychain.sh" = {
      source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/bin/init-keychain.sh";
      force = true;
    };
  };

  programs.home-manager.enable = true;
}
