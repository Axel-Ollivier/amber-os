# === Amber zsh ===
setopt AUTO_CD HIST_IGNORE_DUPS SHARE_HISTORY
HISTFILE=~/.zsh_history; HISTSIZE=50000; SAVEHIST=50000

# completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "di=38;5;180:ln=38;5;215"

# Autosuggestions
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#C98A52"

# fzf — Amber colors
export FZF_DEFAULT_OPTS="--color=bg+:#1f1813,fg:#E8D5BC,fg+:#FFB454,hl:#E8743B,hl+:#FFB454,prompt:#CC785C,pointer:#FFB454,info:#C98A52,border:#5a4632"
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh

# modern CLIs (guards: enabled only if installed)
command -v eza >/dev/null && {
  alias ls='eza --group-directories-first --icons'
  alias ll='eza -lah --git --group-directories-first --icons'
  alias la='eza -a --icons'
  alias lt='eza --tree --level=2 --icons'
}
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v starship >/dev/null && eval "$(starship init zsh)"

# syntax highlighting (MUST stay last)
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#8FB36B'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#FFB454'
ZSH_HIGHLIGHT_STYLES[path]='fg=#C98A52'
