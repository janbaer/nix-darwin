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

  programs = {
    git = import ./programs/git.nix {inherit config pkgs;};
    tmux = import ./programs/tmux.nix {inherit pkgs;};
    zsh = import ./programs/zsh.nix {inherit config pkgs lib; };
    zoxide = (import ./programs/zoxide.nix { inherit config pkgs; });
    fzf = import ./programs/fzf.nix {inherit pkgs;};
    # direnv = import ./programs/direnv.nix {inherit pkgs;};
  };

  home.packages = with pkgs; [
    # superfile   # Another nice and fancy TUI based filemanager
    # devenv      # Fast, Declarative, Reproducible, and Composable Developer Environments
  ];

  home.sessionVariables = {
    SSH_SK_PROVIDER = "/usr/local/lib/libsk-libfido2.dylib";
    SSH_ASKPASS = "/opt/homebrew/bin/ssh-askpass";
    SSH_AUTH_SOCK_LOCAL = "/private/tmp/com.apple.launchd.2kMRnNrA1N/Listeners";
    SSH_AUTH_SOCK = "/private/tmp/com.apple.launchd.p1DRKW2MxY/Listeners";
  };

  home.file = {
    ".tmux".source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.tmux";
    ".tmux.conf".source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.tmux.conf";
    ".gitattributes".source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.gitattributes";
    ".gitconfig".source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.gitconfig";
    ".gitconfig_check24".source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.gitconfig_check24";
    ".config/zsh".source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/zsh";
    ".zshenv".source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.zshenv";
    ".config/lf".source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/lf";
    ".config/lazygit".source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/lazygit";
    ".config/nvim".source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/nvim";
    ".config/Code".source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/Code";
    ".config/powerline".source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/powerline";
    ".config/atuin".source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/atuin";
    ".config/ghostty".source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.config/ghostty"; 
    ".fzf-init.zsh".source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.fzf-init.zsh";
    ".p10k.zsh".source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/.p10k.zsh";
    "bin/init-keychain.sh".source = mkOutOfStoreSymlink "/Users/jan.baer/Projects/dotfiles/bin/init-keychain.sh";
  };

  programs.home-manager.enable = true;
}
