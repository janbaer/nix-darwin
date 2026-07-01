{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  username = "jan.baer";
  dotfiles = "/Users/${username}/Projects/dotfiles";

  claudeSkills = [
    "brainstorm"
    "caveman"
    "forgejo-issue-create"
    "gitlab-mr-review"
    "grill-me"
    "handoff"
    "howcani"
    "obsidian"
    "security-advisory-triage"
    "security-check"
    "shape"
    "ubuntu-cve-lookup"
  ];

  mkSkillSymlink = name: {
    name = ".claude/skills/${name}";
    value = {
      source = mkOutOfStoreSymlink "${dotfiles}/.claude/skills/${name}";
      force = true;
    };
  };
in {
  home.stateVersion = "24.11";

  home.username = "${username}";
  home.homeDirectory = "/Users/${username}";

  xdg.enable = true;

  home.packages = with pkgs; [
    # Ansible related tools
    ansible-lint  # Linter for Ansible

    ncdu

    devbox        # Devbox CLI

    uv            # Extremely fast Python package installer and resolver, written in Rust
    volta         # Node Version Manager
    gojq

    aichat        # CLI for interacting with AI models, supporting multiple providers (e.g., OpenAI, Anthropic, Azure)

    (import ./programs/ghostty.nix {
      inherit pkgs;
      version = "1.3.1";
      sha256  = "sha256-GM/ysKbO6Q7q2cfTBk6AiiUqQLryFKp1LB7LeTuPX2k=";
    })

    # trivy — pinned to 0.71.0 with Go 1.25
    # To get hashes: set both to pkgs.lib.fakeHash, run darwin-rebuild switch,
    # then copy the "got" values from the error output.
    (import ./programs/trivy.nix {
      inherit pkgs;
      version    = "0.71.1";
      sha256     = "sha256-wlvG8iGPBbHV66SOT0zek2VN1QawksVQwM9LSEItzh4=";
      vendorHash = "sha256-n5eWyKpG47LuXPzMO+/tzhFs4F+grWQAThCoGEMQ2S8=";
      goBuilder  = pkgs.buildGo126Module;
    })
  ];

  programs = {
    git = import ./programs/git.nix {inherit config pkgs;};
    tmux = import ./programs/tmux.nix {inherit pkgs;};
    zsh = import ./programs/zsh.nix {inherit config pkgs lib; };
    zoxide = (import ./programs/zoxide.nix { inherit config pkgs; });
    fzf = import ./programs/fzf.nix {inherit pkgs;};
    yazi = import ./programs/yazi.nix {inherit pkgs;};
    direnv = import ./programs/direnv.nix { inherit pkgs; };
  };


  home.sessionVariables = {
    SSH_SK_PROVIDER = "/usr/local/lib/libsk-libfido2.dylib";
    SSH_ASKPASS = "/opt/homebrew/bin/ssh-askpass";
    SSH_AUTH_SOCK_LOCAL = "/private/tmp/com.apple.launchd.2kMRnNrA1N/Listeners";
    SSH_AUTH_SOCK = "/private/tmp/com.apple.launchd.p1DRKW2MxY/Listeners";
    VOLTA_HOME = "$HOME/.volta";
  };

  home.file = (lib.listToAttrs (map mkSkillSymlink claudeSkills)) // {
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
    # ".zshenv" = {
    #   source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.zshenv";
    #   force = true;
    # };
    "Library/Application Support/lazygit/config.yml" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/lazygit/config.yml";
      force = true;
    };
    ".config/nvim" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/neovim/config";
      force = true;
    };
    ".config/Code" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/Code";
      force = true;
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
    ".claude/commands" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.claude/commands";
      force = true;
    };
    ".claude/hooks" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.claude/hooks";
      force = true;
    };
    ".claude/rules" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.claude/rules";
      force = true;
    };
    ".claude/CLAUDE.md" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.claude/CLAUDE.md";
      force = true;
    };
    ".claude/ABOUTME.md" = {
      source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.claude/ABOUTME.md";
      force = true;
    };
  };

  programs.home-manager.enable = true;
}
