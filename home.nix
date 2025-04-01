{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in {
  home.stateVersion = "24.11";
  home.username = "jan.baer";
  home.homeDirectory = "/Users/jan.baer";

  xdg.enable = true;

  programs = {
    git = import ./programs/git.nix {inherit config pkgs;};
    tmux = import ./programs/tmux.nix {inherit pkgs;};
    zsh = import ./programs/zsh.nix {inherit config pkgs lib; };
    zoxide = (import ./programs/zoxide.nix { inherit config pkgs; });
    fzf = import ./programs/fzf.nix {inherit pkgs;};
    direnv = import ./programs/direnv.nix {inherit pkgs;};
  };

  home.packages = with pkgs; [
    httpie
    pwgen
    fd          # Required for Nvim Telescope plugin for repository search
    superfile   # Another nice and fancy TUI based filemanager
    devenv      # Fast, Declarative, Reproducible, and Composable Developer Environments
  ];

  home.file = {
    ".tmux".source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/.tmux";
    ".tmux.conf".source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/.tmux.conf";
    ".gitattributes".source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/.gitattributes";
    ".gitconfig".source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/.gitconfig";
    ".gitconfig_check24".source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/.gitconfig_check24";
    ".config/zsh".source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/.config/zsh";
    ".zshenv".source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/.zshenv";
    ".config/lf".source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/.config/lf";
    ".config/lazygit".source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/.config/lazygit";
    ".config/nvim".source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/.config/nvim";
    ".config/Code".source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/.config/Code";
    ".config/powerline".source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/.config/powerline";
    ".config/atuin".source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/.config/atuin";
    ".config/ghostty".source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/.config/ghostty"; 
    ".fzf-init.zsh".source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/.fzf-init.zsh";
    ".p10k.zsh".source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/.p10k.zsh";
  };

  programs.home-manager.enable = true;
}
