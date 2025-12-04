# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# p10k start
source ~/powerlevel10k/powerlevel10k.zsh-theme

# Cargo settings and mise-en-place
eval "$(mise activate zsh)"
export PATH=$HOME/.local/bin:$PATH

# Alias from alternatives in rust
alias ls="eza --icons --group-directories-first"
alias ll='eza -l --icons --git -a --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias cat="bat --style=auto"
alias vi="nvim"
alias vim="nvim"

# Personal keybindings
bindkey "^[[3~" delete-char
bindkey "^[[1;5D" backward-word
bindkey "^[[1;3D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;3C" forward-word

# zsh syntax highlighting start
source /home/diogo/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
