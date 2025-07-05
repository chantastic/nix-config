# visual.zsh: Override $VISUAL with most modern installet program
if command -v nvim >/dev/null 2>&1; then
  export VISUAL="nvim"
elif command -v vim >/dev/null 2>&1; then
  export VISUAL="vim"
else
  export VISUAL="vi"
fi 

# Override vi with the most modern installet program
vi() {
  if [[ -z "$VISUAL" ]]; then
    echo "Error: $VISUAL is not set" >&2
    return 1
  fi
  "$VISUAL" "$@"
}

compdef _command vi 