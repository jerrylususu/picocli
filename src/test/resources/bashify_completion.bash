#!/usr/bin/env bash
#
# bashify Bash Completion
# =======================
#
# Bash completion support for the `bashify` command,
# generated by [picocli](http://picocli.info/) version %1$s.
#
# Installation
# ------------
#
# 1. Source all completion scripts in your .bash_profile
#
#   cd $YOUR_APP_HOME/bin
#   for f in $(find . -name "*_completion"); do line=". $(pwd)/$f"; grep "$line" ~/.bash_profile || echo "$line" >> ~/.bash_profile; done
#
# 2. Open a new bash console, and type `bashify [TAB][TAB]`
#
# 1a. Alternatively, if you have [bash-completion](https://github.com/scop/bash-completion) installed:
#     Place this file in a `bash-completion.d` folder:
#
#   * /etc/bash-completion.d
#   * /usr/local/etc/bash-completion.d
#   * ~/bash-completion.d
#
# Documentation
# -------------
# The script is called by bash whenever [TAB] or [TAB][TAB] is pressed after
# 'bashify (..)'. By reading entered command line parameters,
# it determines possible bash completions and writes them to the COMPREPLY variable.
# Bash then completes the user input if only one entry is listed in the variable or
# shows the options if more than one is listed in COMPREPLY.
#
# References
# ----------
# [1] http://stackoverflow.com/a/12495480/1440785
# [2] http://tiswww.case.edu/php/chet/bash/FAQ
# [3] https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# [4] http://zsh.sourceforge.net/Doc/Release/Options.html#index-COMPLETE_005fALIASES
# [5] https://stackoverflow.com/questions/17042057/bash-check-element-in-array-for-elements-in-another-array/17042655#17042655
# [6] https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion.html#Programmable-Completion
#

if [ -n "$BASH_VERSION" ]; then
  # Enable programmable completion facilities when using bash (see [3])
  shopt -s progcomp
elif [ -n "$ZSH_VERSION" ]; then
  # Make alias a distinct command for completion purposes when using zsh (see [4])
  setopt COMPLETE_ALIASES
  alias compopt=complete
fi

# ArrContains takes two arguments, both of which are the name of arrays.
# It creates a temporary hash from lArr1 and then checks if all elements of lArr2
# are in the hashtable.
#
# Returns zero (no error) if all elements of the 2nd array are in the 1st array,
# otherwise returns 1 (error).
#
# Modified from [5]
function ArrContains() {
  local lArr1 lArr2
  declare -A tmp
  eval lArr1=("\"\${$1[@]}\"")
  eval lArr2=("\"\${$2[@]}\"")
  for i in "${lArr1[@]}";
  do
    if [ -n "$i" ] ; then ((++tmp[$i])); fi
  done
  for i in "${lArr2[@]}";
  do
    if [ -n "$i" ] && [ -z "${tmp[$i]}" ] ; then return 1; fi
  done
  return 0
}

# Bash completion entry point function.
# _complete_bashify finds which commands and subcommands have been specified
# on the command line and delegates to the appropriate function
# to generate possible options and subcommands for the last specified subcommand.
function _complete_bashify() {


  # No subcommands were specified; generate completions for the top-level command.
  _picocli_bashify; return $?;
}

# Generates completions for the options and subcommands of the `bashify` command.
function _picocli_bashify() {
  # Get completion data
  local curr_word=${COMP_WORDS[COMP_CWORD]}
  local prev_word=${COMP_WORDS[COMP_CWORD-1]}

  local commands=""
  local flag_opts=""
  local arg_opts="-x"
  local _AB_C_option_args="1" # -x values

  compopt +o default

  case ${prev_word} in
    -x)
      read -d ' ' -a COMPREPLY < <(compgen -W "${_AB_C_option_args}" -- "${curr_word}")
      return $?
      ;;
  esac

  if [[ "${curr_word}" == -* ]]; then
    read -d ' ' -a COMPREPLY < <(compgen -W "${flag_opts} ${arg_opts}" -- "${curr_word}")
  else
    read -d ' ' -a COMPREPLY < <(compgen -W "${commands}" -- "${curr_word}")
  fi
}

# Define a completion specification (a compspec) for the
# `bashify`, `bashify.sh`, and `bashify.bash` commands.
# Uses the bash `complete` builtin (see [6]) to specify that shell function
# `_complete_bashify` is responsible for generating possible completions for the
# current word on the command line.
# The `-o default` option means that if the function generated no matches, the
# default Bash completions and the Readline default filename completions are performed.
complete -F _complete_bashify -o default bashify bashify.sh bashify.bash
