# Template files I use in DEVONthink

This contains template files that I use for creating certain kinds of new documents from within DEVONthink. Beware that these are extremely idiosyncratic to my way of doing things, and moreover, make a lot of assumptions about other software I use, and other things I set up in DEVONthink (like smart rules), so they are unlikely to be useful as-is for anyone else. Still, I need to keep them in version control _somewhere_, so they're here.

Note that some of these may be old and no longer in active use.

## Setup

DEVONthink doesn't provide a way for users to store their templates in a user-defined location. To be accessible in DEVONthink, template files _must_ be located in these locations:

* `~/Library/Application Support/DEVONthink 3/Annotations.noindex` (for creating annotation files from the _Annotations & Reminders_ inspector)
* `~/Library/Application Support/DEVONthink 3/Templates.noindex` (for creating new documents using the menu item <em>Data</em> ▹<em>New From Template</em>)

Those folders must exist in those locations, but at the file system level, DEVONthink can't distinguish between an actual directory and a symbolic link to a directory. Thus, what we can do is move those directories elsewhere, and replace the locations above with symbolic links.

```sh
cd "~Library/Application Support/DEVONthink 3"
mv Annotations.noindex ~/projects/software/repos/devonthink-hacks/devonthink-templates/
mv Templates.noindex ~/projects/software/repos/devonthink-hacks/devonthink-templates/
ln -s ~/projects/software/repos/devonthink-hacks/devonthink-templates/Annotations.noindex
ln -s ~/projects/software/repos/devonthink-hacks/devonthink-templates/Templates.noindex
```

DEVONthink includes a lot of default templates, and when you upgrade DEVONthink, it rewrites its default templates in `Templates.noindex`. Thankfully all of those DEVONthink-provided templates are in subdirectories, so we can tell them apart from personal additions. I don't keep their defaults in version control and there's a `.gitignore` file inside `Templates.noindex` here to leave them out of git.

(I personally don't use any of the default templates, and would rather that DEVONthink didn't keep adding them back to my `Templates.noindex` directory. It would be possible to prevent DEVONthink from overwriting `Templates.noindex` by locking the directory, but then it would be a pain to update my own templates. So, I live with the current situation.)

To make the templates available on my iPad and iPhone, I create hard links in an iCloud storage folder. On the Mac, at leat in macOS Ventura, the location of a user's iCloud drive is

```
~/Library/Mobile Documents/com~apple~CloudDocs/
```

Inside that, I create a `DEVONthink templates` directory, then inside _that_, I put hard links to all the template files folder. The files are in a flat organization, without subdirectories, because I don't have enough templates to be worth making it more complicated than that.
