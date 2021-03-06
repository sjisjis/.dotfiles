umask 002

# 入力補完
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
export PATH=~/bin:$PATH
export EDITOR='subl -w'
export JAVA_HOME=`/System/Library/Frameworks/JavaVM.framework/Versions/A/Commands/java_home -v "1.7"`
PATH=${JAVA_HOME}/bin:${PATH}

#docker-machine
if type docker-machine > /dev/null 2>&1;
#    if [[ `docker-machine status dev` -eq 'Stopped' ]];
#        then docker-machine start dev;
#    fi
    then eval "$(docker-machine env dev)"
fi
export DOCKER_API_VERSION=1.22

#lua
export PATH="$(brew --prefix homebrew/versions/lua53)/bin:$PATH"

if [[ -s ~/.nvm/nvm.sh ]];
  then source ~/.nvm/nvm.sh
fi

#pythonbrew
if type pythonbrew > /dev/null 2>&1;
  then
    [[ -s "$HOME/.pythonbrew/etc/bashrc" ]] && source "$HOME/.pythonbrew/etc/bashrc"
    VIRTUALENVWRAPPER_PYTHON=py2.7.3
    source ~/.pythonbrew/bin/virtualenvwrapper.sh
fi

export PATH="$PATH:/Users/$(whoami)/Library/Android/sdk/tools"
export PATH="$PATH:/Users/$(whoami)/Library/Android/sdk/platform-tools"

if [[ "$OSTYPE" =~ darwin ]];then
  jscpath="/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources"
  if [ -f $jscpath/jsc ];then
    export PATH=$PATH:$jscpath
  fi
fi
