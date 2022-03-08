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
alias vi='vim'
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

#rvm
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting$

#bin
export JAVA_HOME=`/usr/libexec/java_home -v "1.8.0_292"`
PATH=${JAVA_HOME}/bin:${PATH}
#export PATH="$HOME/.jenv/bin:$PATH"
#eval "$(jenv init -)"

if [[ -s ~/.nvm/nvm.sh ]];
  then source ~/.nvm/nvm.sh
fi

export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export PATH="$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/tools:$PATH"
export PATH="$PATH:$ANDROID_SDK_ROOT/tools"
export PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools"

if [[ "$OSTYPE" =~ darwin ]];then
  jscpath="/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources"
  if [ -f $jscpath/jsc ];then
    export PATH=$PATH:$jscpath
  fi
fi

export PATH="$HOME/.yarn/bin:$PATH"

#Rust
export PATH="$HOME/.cargo/bin:$PATH"

#Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

#mysql
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"


#sdkman
export SDKMAN_DIR="/Users/shouji/.sdkman"
[[ -s "/Users/shouji/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/shouji/.sdkman/bin/sdkman-init.sh"

#flutter
export PATH="$PATH:$HOME/app/flutter/bin"
export PATH="$HOME/bin:$PATH"
