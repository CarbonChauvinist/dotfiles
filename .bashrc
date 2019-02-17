#
# ~/.bashrc
#

# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !

export EDITOR="$(command -v vim)"
export VISUAL="$EDITOR"
export SUDO_EDITOR="$EDITOR"

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

# TMUX
if which tmux >/dev/null 2>&1; then
   #if not inside a tmux session, and if no session is started, start a new session
   test -z "$TMUX" && (tmux attach || tmux new-session -s bash)
fi

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

# Disable completion when the input buffer is empty.  i.e. Hitting tab
# and waiting a long time for bash to expand all of $PATH.
shopt -s no_empty_cmd_completion

# Enable history appending instead of overwriting when exiting.  #139609
shopt -s histappend

# Save each command to the history file as it's executed.  #517342
# This does mean sessions get interleaved when reading later on, but this
# way the history is always up to date.  History is not synced across live
# sessions though; that is what `history -n` does.
# Disabled by default due to concerns related to system recovery when $HOME
# is under duress, or lives somewhere flaky (like NFS).  Constantly syncing
# the history will halt the shell prompt until it's finished.
#PROMPT_COMMAND='history -a'

PATH=$PATH:/home/ghost/scripts

source /usr/share/doc/pkgfile/command-not-found.bash
source /usr/share/bash-completion/bash_completion

# Get color support for 'less'
export LESS="--RAW-CONTROL-CHARS"

# Use colors for less, man, etc.
[[ -f ~/.LESS_TERMCAP ]] && . ~/.LESS_TERMCAP

###########
# Functions
###########
aurremove() {
	repo-remove /var/cache/pacman/myrepo/myrepo.db.tar "$@"
}

mm() {
    mpv --no-video --ytdl-format=bestaudio ytdl://ytsearch:"$@"
}

# fh - repeat history
fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

md() { pandoc "$1" | lynx -stdin; }

mdp() { pandoc -t plain "$1" | less; }

transfer() { 
  if [ $# -eq 0 ]; then 
	echo -e "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"; 
	return 1; 
  fi 
  tmpfile=$( mktemp -t transferXXX ); 
  if tty -s; then 
	basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g'); 
        curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile; else 
		curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile ; 
  fi; 
cat $tmpfile; 
rm -f $tmpfile; 
} 

wp() {
  if [ -f /home/ghost/Pictures/BingWallpapers/$(date +%Y%m%d).jpg ]; then
	echo -e "Already got it Bro!";
		else
			bingme && ngme;
  fi
}

#######
# Hints
#######

#foo 2>&1 | curl -F 'f:1=<-' ix.io #pastebin from commandline
#foo | curl -F c=@- https://ptpb.pw 
#curl -F'file=@yourfile.png' https://0x0.st #upload image from commandline
#expac -S '%r/%n: %D' foo #find package dependencies
#mount -o remount,size=6G,noatime /tmp #resize tmp
#diff <(pactree -sd1 ffmpeg) <(pactree -d1 ffmpeg) #compare diff output of two commands
#for i in {1..13}; do history -d 4360; done #delete history starting a line 4360 and deleting 13 lines from that start
#zgrep CONFIG_KVM /proc/config.gz #search config current kernel CONFIG
#grep -a, --text Process a binary file as if it were text;

#########
# History
#########
HISTIGNOR="ls:exit:reset:clear:cd*:c:tmux:history*:man*:sudo pacman*:aur sync:sudo pacsync"
HISTCONTROL=ignoreboth:erasedups

# After each comman, save and reload history
#export PROMPT_COMMAND="history -a; history -c; history -r;$PROMPT_COMMAND"
#export PROMPT_COMMAND="history -n; history -w; history -c; history -r;$PROMPT_COMMAND"

# After each command, append to the history file and reread it
#export PROMPT_COMMAND=”${PROMPT_COMMAND:+$PROMPT_COMMAND;’\n’}history -a; history -c; history -r”

HISTSIZE=19000
HISTFILESIZE=20000

# include date and timestamp with history
HISTTIMEFORMAT='%F %T  '

#########
# Aliases
#########
alias pacnew='find /etc -regextype posix-extended -regex ".+\.pac(new|save)" 2>/dev/null'
alias ip='ip --color'
alias p='pacman'
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias c=clear
alias wifiscan='sudo iw dev wifi0 scan | grep -e SSID -e signal:'
alias reauth='sudo systemctl reload-or-restart wpa_supplicant@wifi0.service'
alias reflectme="sudo reflector --country 'United States' --latest 1000 --protocol https -f 15 --save /etc/pacman.d/mirrorlist"
alias d="kitty +kitten diff"
alias st='st -f "FantasqueSansMono Nerd Font Mono:size=12" -g 140x40 -e tmux a'
alias wo='pacman -Qo "$1"'
alias ptpb='curl -F c=@- https://ptpb.pw'
#alias wp='bingme && ngme'
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME --no-pager'
alias graph='git log --all --decorate --oneline --graph'
alias dotfilesgraph='dotfiles log --all --decorate --oneline --graph'

PS1='[\u@\h \W]\$ '
export PYTHONPATH=/usr/lib/python3.7/site-packages/powerline/bindings/bash
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/lib/python3.7/site-packages/powerline/bindings/bash/powerline.sh
