# =============================================================================
# @file    Makefile
# @brief   Trivial makefile for compiling AppleScript
# @author  Michael Hucka
# @date    2022-09-21
# @license Please see the file named LICENSE in the project directory
# @website https://github.com/mhucka/devonthink-hacks
# =============================================================================

# Getting GNU Make to deal with spaces in file names is incredibly painful. The
# first thing done here is to bypass regular GNU Make file pattern matching by
# using find and quoting spaces in the results.

sources = $(shell find . -iname '*.applescript' | sed 's/ /\\ /g')

# The next few lines defines a pattern rule for %.applescript -> %.scpt that
# works for file names that may have spaces in them. It uses a trick I found
# in a Stack Overflow answer by user "mathematical.coffee" posted on 2014-02-11
# at https://stackoverflow.com/a/21694624/743730

space:=
space+=

.SECONDEXPANSION:
%.scpt: $$(subst $$(space),\$$(space),%).applescript
	osacompile -o "$@" "$<"

# Finally, the command to compile files:

compile: $(sources:.applescript=.scpt)
