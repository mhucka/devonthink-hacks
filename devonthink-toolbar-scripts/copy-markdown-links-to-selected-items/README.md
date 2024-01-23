# Copy Markdown links to selected items

For each item selected in the frontmost window of DEVONthink, this copies to the clipboard a link to the item in Markdown format. The name of the link is the name of the item in DEVONthink, and the link URL has the form `x-devonthink-item://UUID`. For example, if you select a document named "Some document" and run this script, it will create a link that looks something like this:

```md
[Some document](x-devonthink-item://6C764-014F-4DDC-B074-054637F5)
```

If multiple items are selected in DEVONthink, the links put in the clipboard are separated by line breaks.

## Compilation and installation

The make procedures require the programs [ImageMagick](https://imagemagick.org/index.php) and [fileicon](https://github.com/mklement0/fileicon). Running `make compile` followed by `make install` in this directory will compile the AppleScript file, give it an icon, and copy the results to two locations:

```txt
~/Library/Application Scripts/com.devon-technologies.think3/Menu/
~/Library/Application Scripts/com.devon-technologies.think3/Toolbar/
```

By putting it in both locations, the program becomes accessible from both the _Scripts_ menu item that appears in certain window contexts in DEVONthink, and as individual toolbar items you can add to the toolbar in certain other contexts. (For example, in windows showing single documents like Markdown documents, there is no _Scripts_ toolbar item available, but programs you install in the `~/Library/.../Toolbar/` location become available as individual toolbar items after you restart DEVONthink.)


## About the icon

The [vector artwork](https://thenounproject.com/icon/share-link-875784/) used as a starting point for the icon created by [Arunkumar](https://thenounproject.com/arun122/) for the [Noun Project](https://thenounproject.com).  It is licensed under the Creative Commons [Attribution 3.0 Unported](https://creativecommons.org/licenses/by/3.0/deed.en) license.
