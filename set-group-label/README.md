set-group-label-_N_
=================

This script is meant to be attached to a group in DEVONthink.  It will automatically assign a label to the contents of the group.  The label is indicated by the number in the file name; for example, `set-group-label-1` assigns whatever is the first label.  This indirect method is needed because you can't pass arguments to the scripts invocations when scripts are assigned to groups in DEVONthink, which means that there's no way for the script to know which label should be assigned.  The only way to assign a specific label is if the script itself figures it out.  I chose to have different scripts for the different labels, and pick which label is used by choosing the appropriate script.
