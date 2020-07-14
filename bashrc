#########
# General
#########
export EDITOR=nvim

export CLICOLOR=2
export LSCOLORS="exfxxxxxgxxxxxxxxxxxxx"

# set prompt command
source ${HOME}/.mpprompt

# PATH
export PATH=${PATH}:${HOME}/code/bin

if [ "$(uname)" == "Darwin" ]; then
  brewPrefix=$(brew --prefix 2> /dev/null || echo /usr/local)
  export PATH="${brewPrefix}/opt/coreutils/libexec/gnubin:${PATH}"
  export PATH="${PATH}:/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin"
  export PATH="${brewPrefix}/opt/gnu-sed/libexec/gnubin:${PATH}"
  export PATH="${brewPrefix}/opt/make/libexec/gnubin:${PATH}"
  export PATH="${brewPrefix}/opt/grep/libexec/gnubin:${PATH}"
  export PATH="${brewPrefix}/opt/findutils/libexec/gnubin:${PATH}"
  export PATH="${brewPrefix}/opt/gnu-tar/libexec/gnubin:${PATH}"
  [ -f /"${brewPrefix}/etc/bash_completion" ] && . "${brewPrefix}/etc/bash_completion"
else
  [ -f /usr/share/bash-completion/bash_completion ] && source /usr/share/bash-completion/bash_completion
fi

# cli fuzzy finder
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

##############
# Bash Aliases
##############
alias la='ls -la'
alias ll='ls -l'
alias l='ls'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias c='clear'
alias fhere='find . -name'
alias mkdir='mkdir -pv'

alias envuo='environments use-orchestra'
alias envu='environments use'


##########
## History
##########
export PROMPT_COMMAND="${PROMPT_COMMAND}; "'if [ "$(id -u)" -ne 0 ]; then echo "$(date +%Y-%m-%d.%H:%M:%S) $(pwd) $(history 1)" >> ~/.logs/bash-history-$(date +%Y-%m-%d).log; fi'
export HISTCONTROL=ignoredups:erasedups # avoid duplicates
shopt -s histappend # append history when shell exists
# After each command, append to the history file and re-read it
export PROMPT_COMMAND="${PROMPT_COMMAND}; history -a; history -c; history -r"

#############
# Git Aliases
#############
alias g='git'

alias gst='git status'
alias ga='git add --all'
alias gcm='git commit -m'
alias gl='git log --oneline --decorate --graph'
alias gla='git log --oneline --decorate --graph --all'
alias glo='git log --oneline'
alias ggpull='git pull origin $(_git_current_branch)'

###########
# Go Config
###########
export GOROOT=/usr/lib/go
export GOPATH=${HOME}/code/go
export PATH=$PATH:${GOPATH}/bin
export PATH=$PATH:${GOROOT}/bin

#############
# Rust Config
#############
export PATH=$PATH:${HOME}/.cargo/bin

#########
# kubectl
#########
# bash completion
source <(kubectl completion bash)

[ -f ~/.kubectl-aliases ] && source ~/.kubectl-aliases
complete -F __start_kubectl k

color-diff-kubectl() {
  local verb resource id
  readonly verb="$1"; shift
  readonly resource="$1"; shift
  readonly id="$1"; shift
  kubectl "${verb}" "${resource}" "${id}" -w -o json \
    | jq -c --unbuffered . \
    | bash -c 'PREV="{}"; while read -r NEXT; do diff -u <(echo -E "$PREV" \
    | jq .) <(echo -E "$NEXT" \
    | jq .); PREV=$NEXT; echo; done' \
    | colordiff
}

alias knodesusage='kubectl describe nodes | grep -A5 "Allocated resources"'

###########
# Functions
###########

take() { mkdir $1 && cd $1; }

mkbashf() {
  if [ -f "$1" ]; then
    echo >&2 "File already exists: $1"
    return 1
  fi
  cat << EOF > $1
#!/usr/bin/env bash

set -o pipefail -o errtrace -o errexit -o nounset
shopt -s inherit_errexit

[[ -n "\${TRACE:-}"  ]] && set -o xtrace

declare errmsg="ERROR (\${0##*/})":
trap 'echo >&2 \$errmsg trap on error \(rc=\${PIPESTATUS[@]}\) near line \$LINENO' ERR

main() {

}

main "\$@"
EOF
  chmod +x "$1"
}

# extracts decompresses any compressed file format
function extract {
  if [ -z "$1" ]; then
    # display usage if no parameters given
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
    return 0
  else
    for n in $@; do
      if [ -f "$n" ] ; then
        case "${n%,}" in
          *.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar) tar xvf "$n";;
          *.lzma) unlzma ./"$n";;
          *.bz2) bunzip2 ./"$n";;
          *.rar) unrar x -ad ./"$n";;
          *.gz) gunzip ./"$n";;
          *.zip) unzip ./"$n";;
          *.z) uncompress ./"$n";;
          *.7z|*.arj|*.cab|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.rpm|*.udf|*.wim|*.xar) 7z x ./"$n";;
          *.xz) unxz ./"$n";;
          *.exe) cabextract ./"$n";;
          *)
            echo "extract: '$n' - unknown archive method"
            return 1
            ;;
        esac
      else
        echo "'$n' - file does not exist"
        return 1
      fi
    done
  fi
}

_git_current_branch() {
  git branch | grep \* | cut -d ' ' -f2
}

