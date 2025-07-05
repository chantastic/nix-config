# editor.zsh: Override $EDITOR with most modern installet program
if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
elif command -v vim >/dev/null 2>&1; then
  export EDITOR="vim"
else
  export EDITOR="vi"
fi 