-- ======================================================================
-- @file    insert-tags-into-markdown.applescript
-- @brief   Find a line that begins with "tags:" & append document tags
-- @author  Michael Hucka <mhucka@caltech.edu>
-- @license MIT license; please see the file LICENSE in the repo
-- @repo    https://github.com/mhucka/devonthink-hacks
--
-- This code is based on code posted by Christian Grunenberg to a
-- DEVONthink forum in April 2020 at
-- https://discourse.devontechnologies.com/t/help-with-a-way-script-to-copy-dt-tags-to-first-line-of-md-file/55057/2
-- ======================================================================

tell application id "DNtp"
	repeat with theRecord in (selection as list)
		if type of theRecord is markdown then
			set theText to plain text of theRecord
			set theTags to ""
			set theTagList to tags of theRecord
			if (count of theTagList) is greater than 0 and theText begins with "Tag:" then
				repeat with theTag in theTagList
					if theTags is not "" then set theTags to theTags & ", "
					set theTags to theTags & "#" & theTag
				end repeat
				set theText to "tag: " & theTags & return & return & theText
				set plain text of theRecord to theText
			end if
		end if
	end repeat
end tell
