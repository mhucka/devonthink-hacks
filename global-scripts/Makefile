# My generic Makefile for compiling AppleScript files.
#
# Copyright 2024 Michael Hucka.
# License: MIT License – see file "LICENSE" in the project website.
# Website: https://github.com/mhucka/devonthink-hacks

# Preliminary settings and tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SHELL=/bin/bash
.ONESHELL:                              # Run all commands in the same shell.
.SHELLFLAGS += -e                       # Exit at the first error.

thisdir := $(shell basename $(CURDIR))

# When I run M-x compile using this Makefile, the compile target works but the
# install target fails. It works outside Emacs in a regular shell terminal. I
# haven't figured out the reason, so for now, this test reminds me to avoid it.

ifeq ($(origin INSIDE_EMACS),environment)
$(error "Do not run make from inside Emacs with this Makefile.")
endif


# Print help if no command is given ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# The help scheme works by looking for lines that begin with "#:" above the
# definitions of commands. Originally based on code posted to Stack Overflow on
# 2019-11-28 by Richard Kiefer at https://stackoverflow.com/a/59087509/743730

#: Print a summary of available commands.
help:
	@echo "This is the Makefile for $(bright)$(thisdir)$(reset)."
	@echo "Available commands:"
	@echo
	@grep -B1 -E "^[a-zA-Z0-9_-]+\:([^=]|$$)" $(MAKEFILE_LIST) \
	| grep -v -- -- \
	| sed 'N;s/\n/###/' \
	| sed -n 's/^#: \(.*\)###\([a-zA-Z0-9_-]*\):.*/$(color)\2$(reset):###\1/p' \
	| column -t -s '###'


# Compile source files ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Getting Make to handle path names with embedded spaces is insanely hard.
# The following incredibly obscure workarounds are the combination of two
# methods: (1) by user "mathematical.coffee" posted on 2014-02-11
# at https://stackoverflow.com/a/21694624/743730, and (2) by user Yann-Gaël
# Guéhéneuc posted on 2016-02-25 at https://stackoverflow.com/a/35617603/743730

# We first create a list of source files in a way that bypasses the regular
# Make file pattern matching, and then replace every space character in
# each pathname with a question mark character.

sources = $(shell find . -iname '*.applescript' | cut -d/ -f2- | tr ' ' '?')

# Next, define a function named "q2s" to replace question marks by spaces.

space :=
space +=
q2s = $(subst ?, $(space),$1)

# Now define the pattern rule to create compile .scpt files from .applescript
# files. A rule of the form %.scpt would not work if the file names had space
# characters in them (because the outcome of Make expanding %.scpt would have
# spaces in the result, and those spaces would act as file name delimiters).
# But if the file names used with this pattern rule have question marks
# instead of spaces, they're atomic units as far as the pattern matching
# mechanism is concerned, and so the rule works. We just have to do some
# substitution to reconstruct the real file names before we run commands that
# act on the files themselves. (That's where q2s comes in.)

.SECONDEXPANSION:
%.scpt: $$(subst $$(space),\$$(space),%).applescript
	osacompile -o "$(call q2s,$*.scpt)" "$<"

# The final ingredient is to define the target "compile" such that it depends
# on a list of .scpt files. This is simply done by taking the list of source
# files (names such as "Some?file?name.applescript") and replacing the
# extensions. The resulting list (names like "Some?file?name.scpt") then
# satisfies the %.scpt rule above.

#: Compile the AppleScript files in this directory.
compile: $(sources:.applescript=.scpt)


# Install binaries ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Note the use of ? in the directory name below, instead of the space character
# (i.e. ~/Library/Application Scripts/com.devon-technologies.think3/Menu).

destdir = "$(HOME)/Library/Scripts"

.SECONDEXPANSION:
$(destdir)/%.scpt: $$(subst $$(space),\$$(space),%).applescript
	install -bpS "$(call q2s,$*.scpt)" $(call q2s,$(destdir))

#: Install the compiled scripts in DEVONthink's script directory.
install: $(addprefix $(destdir)/,$(sources:.applescript=.scpt))


# Cleanup ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#: Clean this directory.
clean:
	rm -rf *.scpt
	@echo ✨ Cleaned! ✨


# Miscellaneous directives ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#: Print a random joke from https://icanhazdadjoke.com/.
joke:
	@echo "$(shell curl -s https://icanhazdadjoke.com/)"

# Color codes used in messages.
color  := $(shell tput bold; tput setaf 6)
bright := $(shell tput bold; tput setaf 15)
dim    := $(shell tput setaf 66)
link   := $(shell tput setaf 111)
reset  := $(shell tput sgr0)

.PHONY: help clean joke

.SILENT: clean
