-- ======================================================================
-- @file    Send URL to Internet Archive.applescript
-- @brief   Send the URL of the selected items to the Internet Archive
-- @author  Michael Hucka <mhucka@caltech.edu>
-- @license MIT license; please see the file LICENSE in the repo
-- @repo    https://github.com/mhucka/devonthink-hacks
--
-- This assumes a metadata field named "archiveurl" exists on the
-- records of your database.
-- ======================================================================

on performSmartRule(theRecords)
	repeat with _record in theRecords
		try
			set theURL to get URL of _record
			set savedURL to do shell script ¬
				"curl -sSI 'https://web.archive.org/save/" & theURL & "' | egrep '^location:' | awk '{print $2}'"
			if savedURL is not in {{}, {""}, ""} then
				add custom meta data savedURL for "archiveurl" to _record
			end if
		on error msg number code
			if the code is not -128 then
				display alert "DEVONthink smart rule" message msg as warning
			end if
		end try
	end repeat
end performSmartRule
