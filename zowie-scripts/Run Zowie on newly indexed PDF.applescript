# =======================================================================
# @file    Run Zowie on newly indexed PDF.applescript
# @brief   Script for DEVONthink smart rule to run Zowie on new additions
# @author  Michael Hucka <mhucka@caltech.edu>
# @license MIT license; please see the file LICENSE in the repo
# @repo    https://github.com/mhucka/devonthink-hacks
# =======================================================================

# The following function is based on code posted by user "mb21" on
# 2016-06-26 at https://stackoverflow.com/a/38042023/743730

on substituted(search_string, replacement_string, this_text)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to ""
	return this_text
end substituted

on performSmartRule(selectedRecords)
	repeat with _record in selectedRecords
		# In my environment, Zotero takes time to upload a newly-added
		# PDF to the cloud. The following delay is needed to give time
		# for the upload to take place, so that when Zowie runs and
		# queries Zotero via the network API, the data will be there.
		delay 30

		set raw_path to the path of the _record

		# Some chars in file names are problematic due to having special
		# meanings in shell command strings.  Need to quote them with 2
		# blackslashes, b/c the 1st backslash will be removed when the
		# shell command string is handed to the shell.
		set sanitized_path to substituted("&", "\\\\&", raw_path)

		# Another problem with file names is embedded single quotes. The
		# combination of changing the text delimiter and using the
		# AppleScript "quoted form of" below, seems to do the trick.
		set AppleScript's text item delimiters to "\\\\"
		set result to do shell script ¬
			"/usr/local/bin/zowie -q " & (quoted form of sanitized_path)

		# Display a DEVONthink notification if an error occurred.
		if result is not equal to "" then
			display notification result
		end if
	end repeat
end performSmartRule
