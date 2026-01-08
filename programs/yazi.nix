{pkgs, ...}: {
  enable = true;
  settings = {
    mgr = {
      show_hidden = true;
      sort_by = "alphabetical";
      sort_dir_first = true;
    };
  };
  keymap = {
    mgr.prepend_keymap = [
      { on = [ "<C-d>" ]; run = "shell --confirm 'sudo rm -rf \"$@\"' -- %s"; desc = "Delete selected files with sudo"; }
      { on = [ "g" "H" ]; run = "cd ~/"; desc = "Go to home directory"; }
      { on = [ "g" "D" ]; run = "cd ~/Documents"; desc = "Go to Documents"; }
      { on = [ "g" "d" ]; run = "cd ~/Downloads"; desc = "Go to Downloads"; }
      { on = [ "g" "P" ]; run = "cd ~/Projects"; desc = "Go to Projects"; }
      { on = [ "g" "p" ]; run = "cd ~/Pictures"; desc = "Go to Pictures"; }
      { on = [ "g" "V" ]; run = "cd ~/Videos"; desc = "Go to Videos"; }
      { on = [ "g" "M" ]; run = "cd ~/Music"; desc = "Go to Music"; }
      { on = [ "g" "c" ]; run = "cd ~/.config"; desc = "Go to .config"; }
      { on = [ "g" "b" ]; run = "cd ~/bin"; desc = "Go to bin"; }
    ];
  };
}
