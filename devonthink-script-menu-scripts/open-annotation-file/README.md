# Open annotation file

DEVONthink 3 has a mechanism that allows you to create a document that stores comments and other content about _another_ document. In DEVONthink, this is called an "annotation file" or sometimes just "annotation" (not to be confused with other kinds of annotations, such as annotations in PDF files). The facility is accessed from the _Annotations & Reminders_ inspector panel, via a drop-down menu accessible by clicking on _Annotations ▾_ in the lower half.

<p align="center">
    <img align="center" width="300px" src="https://github.com/mhucka/devonthink-hacks/blob/main/open-annotation-file/annotations-drop-down.png">
<p>

Editing annotations is much more conveniently done in a separate window. If a document has an annotation file associated with it, the "Open" command is available in the pull-down menu (as shown above). I wanted to have a keyboard shortcut to open annotation files in separate windows, but unfortunately, DEVONthink does not provide a keyboard shortcut for this command; more unfortunately, you can't target this command via macOS's built-in shortcuts facility, and I haven't found a way to invoke it directly via [Keyboard Maestro](https://www.keyboardmaestro.com/main/).

Thankfully, it _is_ possible to write a short AppleScript program to tell DEVONthink to open the annotation file in a new window, and this in turn _can_ be set up as an action in [Keyboard Maestro](https://www.keyboardmaestro.com/main/) with a keyboard shortcut. 

The script in this directory tells DEVONthink to open a new window on the annotation file for the currently-selected document. It will also work if multiple documents are selected when it is invoked.

