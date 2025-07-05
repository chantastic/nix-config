# Set $EDITOR and $VISUAL with fallback logic
if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
elif command -v vim >/dev/null 2>&1; then
  export EDITOR="vim"
else
  export EDITOR="vi"
fi

if command -v nvim >/dev/null 2>&1; then
  export VISUAL="nvim"
elif command -v vim >/dev/null 2>&1; then
  export VISUAL="vim"
else
  export VISUAL="vi"
fi 