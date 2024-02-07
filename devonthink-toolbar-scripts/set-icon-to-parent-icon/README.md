# Set the icon of a selected group to that of its parent

I like to set my group icons in DEVONthink to colorful custom icons. Copy-pasting icons using the inspector has become tedious, so I wrote a script to set the icon of a selected group to that of its parent. The AppleScript code in this directory was made possible thanks to helpful examples and comments from users "pete31" and "chrillek" on the DEVONthink user forums, in these postings:

* [AppleScript to set thumbnail of group to same as parent group?](https://discourse.devontechnologies.com/t/applescript-to-set-thumbnail-of-group-to-same-as-parent-group/69114/3) (code to set thumbnails of child items)
* [AppleScript to set thumbnail of group to same as parent group?](https://discourse.devontechnologies.com/t/applescript-to-set-thumbnail-of-group-to-same-as-parent-group/69114/11) (reminder about `location group`)
* [How to set thumbnails as raw data?](https://discourse.devontechnologies.com/t/how-to-set-thumbnails-as-raw-data/55696)

I put the compiled script in the folder for DEVONthink menubar scripts (which is `~/Library/Application Scripts/com.devon-technologies.think3/Menu/`).


## Compilation and installation

The make procedures require the programs [ImageMagick](https://imagemagick.org/index.php) and [fileicon](https://github.com/mklement0/fileicon). Running `make compile` followed by `make install` in this directory will compile the AppleScript file, give it an icon, and copy the results to two locations:

```txt
~/Library/Application Scripts/com.devon-technologies.think3/Menu/
~/Library/Application Scripts/com.devon-technologies.think3/Toolbar/
```

By putting it in both locations, the program becomes accessible from both the _Scripts_ menu item that appears in certain window contexts in DEVONthink, and as individual toolbar items you can add to the toolbar in certain other contexts. (For example, in windows showing single documents like Markdown documents, there is no _Scripts_ toolbar item available, but programs you install in the `~/Library/.../Toolbar/` location become available as individual toolbar items after you restart DEVONthink.)


## About the icon

The [vector artwork](https://thenounproject.com/icon/copy-308007/) used as a starting point for the icon created by [Tony Wallström](https://thenounproject.com/tonywallstrom/)  It is licensed under the Creative Commons [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/) license.
