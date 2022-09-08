#alias npp="C:/'Program Files'/Notepad++/notepad++.exe&"
alias npp='start notepad++'
alias sadge="echo '=('"

# Enable ls to automatically print colors. Ported from C:\Program Files\Git\etc\profile.d\aliases.sh for use w/o bash -l
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

# If in git repo then fetch outstaging changes to display in prompt, separated by ADD,MOD,DEL,UNTRK status
prompt_git_status(){
	if [ "$DO_CUSTOM_PROMPT" -eq 1 ]; then
		# ANSI Color Codes
		local COLOR_WHITE_ON_GREEN_ESC='\\[\\e[97;102m\\]'
		local COLOR_GREY_ON_YELLOW_ESC='\\[\\e[90;103m\\]'
		local COLOR_WHITE_ON_RED_ESC='\\[\\e[97;101m\\]'
		local COLOR_WHITE_ON_BLUE_ESC='\\[\\e[97;104m\\]'
		local COLOR_NULL_ESC='\\[\\e[0m\\]'
		
		if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]; then
			# Gross bit of code here but much more performant than the previous solution
			echo `git status -s | tee >(grep -c -E '^\s*\?\?' | sed -E s/^/$COLOR_NULL_ESC$COLOR_WHITE_ON_BLUE_ESC\ U:/) >(grep -c -E '^\s*D' | sed -E s/^/$COLOR_NULL_ESC$COLOR_WHITE_ON_RED_ESC\ D:/) >(grep -c -E '^\s*M' | sed -E s/^/$COLOR_NULL_ESC$COLOR_GREY_ON_YELLOW_ESC\ M:/) >(grep -c -E '^\s*A' | sed -E s/^/$COLOR_WHITE_ON_GREEN_ESC\ A:/) >/dev/null`
		fi
	fi
}

# Generate prompt to user utilizing existing prompt as base
prompt_gen(){
	# ANSI Color Codes
	local COLOR_NULL="\[\e[0m\]"
	local COLOR_YELLOW="\[\e[93m\]"
	local COLOR_CYAN="\[\e[96m\]"
	local COLOR_WHITE="\[\e[37m\]"
	
	local prompt_curr_time="\n\[\e[93m\][`date +%r`]"
	
	# Remove (depending on context) from PS1 to get the main prompt content:
	# The \n$SP ending (from the default prompt)
	# The previous prompt_main_sep (and everything after it from prompt_gen)
	# The newline between the main prompt and the window title (from the default prompt)
	# The previous prompt_curr_time (from prompt_gen)
	local prompt_git_main=$(sed -E '
	s/\\n\$\ $// ;
	s/ \\\[\\e\[93m\\\]~.+$// ;
	s/^\\n\\\[\\e\[93m\\\]\[[^]]*\]// ;
	s/\\n\\\[\\033\[32m\\]/ \\[\\e[32m\\]/
	' <<< "$PS1")
	
	# Append a standard separator that will be used to overwrite custom content on next pass
	local prompt_main_sep=" $COLOR_YELLOW~ "
	# Generate git status portion and append null color to close background coloring
	local prompt_custom_content="`prompt_git_status` $COLOR_NULL"
	local prompt_end_edit="$COLOR_NULL\n$COLOR_CYAN\$>$COLOR_WHITE "
	PS1="$prompt_curr_time$prompt_git_main$prompt_main_sep$prompt_custom_content$prompt_end_edit"
}

# Enivronment variable to enable/disbale prompt_git_status function. If disabled then the custom portions of the prompt will not be generated 
DO_CUSTOM_PROMPT=1

# Ignore consecutive duplicate history entries
HISTCONTROL=$HISTCONTROL:ignoredups

# HISTSIZE is # of cmds loaded in memory vs HISTFILESIZE as # of cmds written to ~/.bash_history file
HISTSIZE=400
HISTFILESIZE=800

# For every command: generate prompt and append command to history
PROMPT_COMMAND="prompt_gen;history -a;history -r;"
