# Custom aliases
alias npp='start notepad++'
alias sadge="echo '=('"
alias gti="git"

# Enable ls to automatically print colors
# For use w/o bash -l (login session); improves performance
# (Ported from C:\Program Files\Git\etc\profile.d\aliases.sh)
alias ls="ls -F --color=auto --show-control-chars"

# Load additional colors to display w/ ls command
test -f ~/.bash_colors || touch ~/.bash_colors
cat /etc/DIR_COLORS > ~/.bash_colors
echo "
# Custom Items
.cmd 01;32
.exe 01;32
.com 01;32
.btm 01;32
.bat 01;32
.sh  01;32
.csh 01;32" >> ~/.bash_colors
eval `dircolors -b ~/.bash_colors`

# Options to C:\Program Files\Git\mingw64\share\git\completion\git-prompt.sh
GIT_PS1_SHOWUPSTREAM="verbose"

# If in git repo, fetch outstaging changes to display in prompt, separated by ADD,MOD,DEL,UNTRK status
prompt_git_file_status(){
	# ANSI Color Codes (ESC versions for use in sed commands)
	local COLOR_WHITE_ON_GREEN_ESC='\\[\\e[97;102m\\]'
	local COLOR_GREY_ON_YELLOW_ESC='\\[\\e[90;103m\\]'
	local COLOR_WHITE_ON_RED_ESC='\\[\\e[97;101m\\]'
	local COLOR_WHITE_ON_BLUE_ESC='\\[\\e[97;104m\\]'
	local COLOR_NULL_ESC='\\[\\e[0m\\]'
	local COLOR_BLACK_ON_BLACK="\[\e[30;40m\]"
	local COLOR_YELLOW="\[\e[93m\]"
	local COLOR_NULL="\[\e[0m\]"
	
	# Check if the current directory is within a git repository
	if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]; then
		# Separate custom git prompt content from the preceding prompt
		echo -n "$COLOR_NULL $COLOR_YELLOW~$COLOR_NULL "
		
		# (Gross bit of code here but much more performant than the previous solution)
		# Parse the output of git status and count the number of files for each captured status (ADD,MOD,DEL,UNTRK)
		# Display each count preceded by the corresponding color and letter label
		echo -n `git status -s | tee \
		>(rg -c --include-zero '^\s*\?\?' | sed -E s/^/$COLOR_NULL_ESC$COLOR_WHITE_ON_BLUE_ESC\ U:/) \
		>(rg -c --include-zero '^\s*D' | sed -E s/^/$COLOR_NULL_ESC$COLOR_WHITE_ON_RED_ESC\ D:/) \
		>(rg -c --include-zero '^\s*M' | sed -E s/^/$COLOR_NULL_ESC$COLOR_GREY_ON_YELLOW_ESC\ M:/) \
		>(rg -c --include-zero '^\s*A' | sed -E s/^/$COLOR_NULL_ESC$COLOR_WHITE_ON_GREEN_ESC\ A:/) \
		>/dev/null`
		
		# Append a closing space to the final status section (UNTRK)
		echo -n " $COLOR_BLACK_ON_BLACK|$COLOR_NULL"
	fi
}

# Generate prompt to user utilizing default MSYS2 prompt as a base
prompt_gen(){
	# ANSI Color Codes
	local COLOR_CYAN="\[\e[96m\]"
	local COLOR_WHITE="\[\e[37m\]"
	local COLOR_YELLOW="\[\e[93m\]"
	
	local prompt_curr_time="\n$COLOR_YELLOW[`date +%r`]"
	local prompt_custom_end="\n$COLOR_CYAN\$>$COLOR_WHITE "
	
	# Start with the MSYS2 default prompt:
	# Remove the newline preceding the prompt
	# Remove the \n$SP prompt ending
	local prompt_root_content=$(sed -E '
	s/\\n\\\[\\033\[32m\\]/ \\[\\e[32m\\]/ ;
	s/\\n\$\ $//
	' <<< "$MSYS2_PS1")
	
	PS1="$prompt_curr_time$prompt_root_content$(prompt_git_file_status)$prompt_custom_end"
}

# Enivronment variable to enable/disbale custom prompt
RENDER_CUSTOM_PROMPT=1

# Ignore consecutive duplicate history entries
HISTCONTROL=$HISTCONTROL:ignoredups

# HISTSIZE is number of cmds loaded in memory vs HISTFILESIZE as number of cmds written to ~/.bash_history file
HISTSIZE=400
HISTFILESIZE=800

# For every command generate prompt (if var set) and append command to history
do_prompt(){
	if [ "$RENDER_CUSTOM_PROMPT" -eq 1 ]; then
		prompt_gen
	fi
	history -a
	history -r
}
PROMPT_COMMAND=do_prompt

# Enable vscode shell integration; code terminal startup time can be improved by hardcoding shell-integration-path
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path bash)"
