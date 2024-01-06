# Switch workspace

I've learned to take advantage of DEVONthink's workspaces to organize windows and documents for different projects and activities. It's been a great feature – one that I didn’t appreciate when I first started to use DEVONthink.  But, with the default DEVONthink commands for changing workspaces, a source of friction for me is remembering to update the current configuration before switching.  In a typical day, I switch workspaces multiple time, and I often forget to use _Go_ ▹ _Workspaces_ ▹ _Update workspace_ to save the current configuration before switching. The result is that I lose any changes made since the last time I used that workspace. For my way of working, the windows currently visible on screen capture a lot of context about what I was in the middle of doing, and losing that context is a problem.

In October 2022, I finally sent a request to the DEVONthink developers for a preference setting that would, when turned on, automatically update the current workspace before switching to another one. The DEVONthink developers said they would consider it. They also sent me a script that, when invoked, asks the user to select a workspace from a list, saves the current workspace, and switches to the selected workspace. This is good enough for me.

A slightly modified version of the script is in this directory. I put the compiled script in the folder for DEVONthink menubar scripts (which is `~/Library/Application Scripts/com.devon-technologies.think3/Menu/`) and I bind a keystroke (in [Keyboard Maestro](https://www.keyboardmaestro.com/main/)) to invoke the script.