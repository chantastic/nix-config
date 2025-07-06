# Source all zsh dotfiles in ~/.config/zsh, except this file (robust to invocation path)
this_file="$(realpath "${(%):-%N}")"
for f in ~/.config/zsh/*.zsh; do
  [[ "$(realpath "$f")" != "$this_file" ]] && source "$f"
done 