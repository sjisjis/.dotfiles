# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
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

#alias grep="grep --color=auto"
alias vi='nvim'
# }}}

#docker
alias d-rm-ps='docker rm -f $(docker ps -qa)'
alias d-rm-img='docker rmi -f $(docker images -qa)'

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

eval "$(nodenv init -)"

# awsp
#function awsp() {
#  if [ $# -ge 1 ]; then
#    export AWS_PROFILE="$1"
#    echo "Set AWS_PROFILE=$AWS_PROFILE."
#  else
#    source _awsp
#  fi
#  export AWS_DEFAULT_PROFILE=$AWS_PROFILE
#}
alias awsp='export AWS_PROFILE=$(aws configure list-profiles | fzf)'

source /Users/takumishoji/.docker/init-zsh.sh || true # Added by Docker Desktop


[[ -f "$HOME/fig-export/dotfiles/dotfile.zsh" ]] && builtin source "$HOME/fig-export/dotfiles/dotfile.zsh"

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
