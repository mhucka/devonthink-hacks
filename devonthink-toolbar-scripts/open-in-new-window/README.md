# Open in new window

For each item selected in the frontmost window of DEVONthink, if the item is a group then this force-opens a new window on the group (even if there is a window open on it somewhere); otherwise, this opens the item in the default application. I wrote this because I wanted to change the behavior of <kbd>⇧</kbd><kbd>⌃</kbd><kbd>o</kbd>. I bind this to a keystroke using [Keyboard Maestro](https://www.keyboardmaestro.com).


## Compilation and installation

The make procedures require the programs [ImageMagick](https://imagemagick.org/index.php) and [fileicon](https://github.com/mklement0/fileicon). Running `make compile` followed by `make install` in this directory will compile the AppleScript file, give it an icon, and copy the results to two locations:

```txt
~/Library/Application Scripts/com.devon-technologies.think3/Menu/
~/Library/Application Scripts/com.devon-technologies.think3/Toolbar/
```

By putting it in both locations, the program becomes accessible from both the _Scripts_ menu item that appears in certain window contexts in DEVONthink, and as individual toolbar items you can add to the toolbar in certain other contexts. (For example, in windows showing single documents like Markdown documents, there is no _Scripts_ toolbar item available, but programs you install in the `~/Library/.../Toolbar/` location become available as individual toolbar items after you restart DEVONthink.)


## About the icon

The [vector artwork](https://thenounproject.com/icon/folder-2062718/) used as a starting point for the icon created by [iejank](https://thenounproject.com/iejankzonks/) for the Noun Project.  It is licensed under the Creative Commons [Attribution 3.0 Unported](https://creativecommons.org/licenses/by/3.0/deed.en) license.
