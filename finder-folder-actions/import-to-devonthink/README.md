# Auto-import to DEVONthink

This is a script meant to be used as a [Folder Actions](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_folder_actions.html) script attached to a folder in the Finder. Its job is to watch for additions to the folder, and when items are added, it will tell DEVONthink to import it with a dialog. It differs from a similar folder action script provided as part of DEVONthink (that one is named _DEVONthink - Import & Delete_) in the following ways:

* If a single item is dropped in the folder, this script will bring up a DEVONthink dialog to ask the user for the destination group, tags to be added, and (optionally) a new name for the item. If the name field is left empty, the script will use the name of the file (minus the path/folder components).
* If multiple items are dropped in the folder, this script will first bring up a dialog to ask the user whether the items should be considered individually or as one group. Depending on the user's answer, the script will then
  * Ask for the name, tags, & destination of each item one at a time, or
  * Ask for tags and destination once, then move all items to that destination and give them all the same tag.
* It catches more errors and provides (hopefully) more meaningful error dialogs.
* It puts original items in the trash unless the user cancels at any time or an error occurs.
