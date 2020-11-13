# =============================================================================
# @file    Makefile
# @brief   Trivial makefile for compiling AppleScript
# @author  Michael Hucka
# @date    2020-11-13
# @license Please see the file named LICENSE in the project directory
# @website https://github.com/mhucka/devonthink-hacks
# =============================================================================

sources = $(shell find . -iname '*.applescript' | sed 's/ /\\ /g')

compile: $(sources:.applescript=.scpt)

%.scpt: %.applescript
	osacompile -o "$@" "$<"
