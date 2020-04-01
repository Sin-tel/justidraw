# justidraw

Experimental DAW.

This is made to work with a drawing tablet on Windows (wintab driver).

# how to run

1. Install the latest version of [love2d](https://love2d.org/)
2. Compress the contents of src to a .zip file (Make sure main.lua is at the top level of the zip)
3. Change the extension from .zip to .love
4. Run the .love file

# controls

## tools
* middle mouse: pan
* hold ctrl: zoom
### freehand draw tool
* left click: draw
* hold ctrl: erase
* hold shift: smooth
### line tool
* left click: draw flat lines
* hold alt: draw slanted lines
* hold ctrl: erase
### pan/zoom tool
* left click: pan
* hold ctrl: zoom
### grab tool
* left click: grab part of note
* hold ctrl: move whole note / selection
### envelope tool
* left click: add
* hold ctrl: subtract
### selection
* left click: normal select
* hold shift: add
* hold ctrl: subtract

## shortcuts
* B: freehand draw (Brush)
* L: Line tool
* E: Eraser
* P: Pan/zoom
* G: Grab
* M: Move
* S: Smooth
* F: Flatten
* R: Rectangular selection
* N: eNvelope tool
* D: Deselect
* [ and ]: chage brush radius (when applicable)
* Space: play/pause
* ctrl+Z: undo
* ctrl+Y / ctrl+shift+Z: redo
* ctrl+S: save 
* ctrl+O: open save folder 


Drag and drop save files to open them!
Your last save file will be loaded on startup.

* Escape: quit
* Delete: clear all
