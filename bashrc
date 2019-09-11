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
  [ -f /usr/local/etc/bash_completion  ] && . /usr/local/etc/bash_completion
fi

# bash completion
source <(kubectl completion bash)

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

##########
## History
##########
export HISTCONTROL=ignoredups:erasedups # avoid duplicates
shopt -s histappend # append history when shell exists
# After each command, append to the history file and re-read it
export PROMPT_COMMAND="${PROMPT_COMMAND}; history -a; history -c; history -r"

#############
# Git Aliases
#############
alias gst='git status'
alias gcmsg='git commit -m'
alias gaa='git add --all'

alias gb='git branch'

alias ggpull='git pull origin $(_git_current_branch)'

alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'

###########
# Go Config
###########
export GOROOT=/usr/local/go
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
alias k='kubectl'
[ -f ~/.kubectl_aliases ] && . ~/.kubectl_aliases
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
    for n in $@
    do
      if [ -f "$n" ] ; then
          case "${n%,}" in
            *.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                         tar xvf "$n"       ;;
            *.lzma)      unlzma ./"$n"      ;;
            *.bz2)       bunzip2 ./"$n"     ;;
            *.rar)       unrar x -ad ./"$n" ;;
            *.gz)        gunzip ./"$n"      ;;
            *.zip)       unzip ./"$n"       ;;
            *.z)         uncompress ./"$n"  ;;
            *.7z|*.arj|*.cab|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.rpm|*.udf|*.wim|*.xar)
                         7z x ./"$n"        ;;
            *.xz)        unxz ./"$n"        ;;
            *.exe)       cabextract ./"$n"  ;;
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
