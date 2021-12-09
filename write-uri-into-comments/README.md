# Write DEVONthink URI into Finder comment

I use the AppleScript included here to write the `x-devonthink-item` URI of a DEVONthink Markdown document into the document's Finder comments, so that when the document is edited or viewed externally, it is possible to find its record in a DEVONthink database. The script is trigged by a DEVONthink Smart Rule that looks like this:

<p align="center">
    <img align="center" width="600px" src="smart-rule-screenshot.png">
<p>

The first part of the Smart Rule action writes the `x-devonthink-item` URI into the Finder comment shown by DEVONthink to the user; the second part is a short AppleScript that invokes [Urial](https://github.com/mhucka/urial). 

The need for both actions is due to how DEVONthink behaves (at least up to version 3.8). When you modify the metadata field called "Finder Comments" in the DEVONthink user interface, it [does not actually write the field value to the macOS file](https://discourse.devontechnologies.com/t/how-can-i-make-finder-comments-added-in-dt-show-up-in-finder-get-info-box/68186) at that point. Thus, merely updating the comment in DEVONthink is not enough to make it visible outside of DEVONthink, and an additional action is needed.

I wrote [Urial](https://github.com/mhucka/urial) to help with this task; the program intelligently updates URIs in Finder comments rather than blindly replacing the comment text. If you don't want to use Urial, you could accomplish most (or all, if you're really motivated) of the same thing by writing some AppleScript or JavaScript code.
