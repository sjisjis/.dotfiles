umask 002

# 入力補完
autoload -U compinit
compinit -u
fpath=(~/.zsh/completion $fpath)

# プロンプト表示 {{{
PROMPT=$'%{\e[31m%}%n@%M %{\e[33m%}%* %# %{\e[m%}'
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'
precmd () {
    psvar=()
    LANG=en_US.UTF-8 vcs_info
    [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}
RPROMPT="%1(v|%F{green}%1v%f|)"
# }}}

# alias export {{{
export LSCOLORS=gxfxcxdxbxegedabagacad

case ${OSTYPE} in
darwin*)
alias ls='ls -G'
alias ll='ls -la'
;;
linux*)
alias ls='ls -G --color'
alias ll='ls -la --color'
;;
esac

alias grep="grep --color=auto"
alias vi='nvim'
# }}}

# History {{{
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000000
SAVEHIST=$HISTSIZE

setopt \
    extended_history \
    hist_ignore_dups \
    hist_ignore_space \
    inc_append_history \
    share_history \
    no_flow_control

autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

bindkey "^N" history-beginning-search-forward-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^R" history-incremental-pattern-search-backward
bindkey "^S" history-incremental-pattern-search-forward
# }}}

#mac image preview
alias ql='qlmanage -p "$@" >& /dev/null'
alias imgsize="mdls -name kMDItemPixelWidth -name kMDItemPixelHeight"

if [ -f ~/.dotfiles/.zshrc-export-path ]; then
  source ~/.dotfiles/.zshrc-export-path
  # Rust: export PATH="$HOME/.cargo/bin:$PATH"
fi

