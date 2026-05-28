# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"
umask 002

# 入力補完
fpath=(~/.zsh/completion $fpath)
autoload -U compinit
compinit -u

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
alias tf="aws-vault exec ${AWS_PROFILE} -- terraform"
alias sz="source ~/.zshrc"

function awsp() {
  local profile=$(aws configure list-profiles | fzf --height 40% --reverse --prompt="AWS Profile > ")

  if [ -n "$profile" ]; then
    export AWS_PROFILE=$profile
    echo "✅ Switched to: $AWS_PROFILE"

    aws sso login
  fi

}
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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

export PATH="$HOME/.claude/local:$PATH"
eval "$(sheldon source)"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
