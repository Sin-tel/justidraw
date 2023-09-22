# justidraw

Experimental DAW.

[![Video of Justidraw in action](http://img.youtube.com/vi/JhLQWR3zdeU/0.jpg)](http://www.youtube.com/watch?v=JhLQWR3zdeU)

For the optimal experience, use with a drawing tablet on Windows (wintab driver).

macOS and Linux work but only mouse input.

# how to run

1. Install the latest version of [love2d](https://love2d.org/)
2. Download the [latest release](https://github.com/Sin-tel/justidraw/releases) (you need the `.love` file)

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
* hold ctrl: move tool
### transpose/stretch tool
* hold shift: only affect time
* hold ctrl: only affect pitch
### move tool
* left click: move whole note / selection
* hold shift while moving: constrain to one axis
* hold ctrl: grab tool
### envelope tool
* left click: draw envelope 
### selection
* left click: normal select
* hold shift: add
* hold ctrl: subtract

## shortcuts
### Tools
* B: freehand draw (Brush)
* P: line tool (Pen)
* E: Eraser
* O: pan/zoom
* G: Grab
* M: Move
* S: Smooth
* F: Flatten
* R: Rectangular selection
* L: Lasso selection
* N: eNvelope tool
* H: Dodge/burn envelope (ctrl to decrease)
* T: Transpose/stretch
* U: smUdge / (ctrl: vibrato)
### Selection
* D: Deselect
* shift+D: duplicate selection
* Delete / backspace: delete selection. clear all when nothing selected
* J: Join ends of selected notes
### File
* Space: play/pause
* ctrl+Z: undo
* ctrl+Y / ctrl+shift+Z: redo
* ctrl+R: render wav
* ctrl+S: save 
* ctrl+O: open save folder 
* Escape: quit
### Misc
* [ and ] : change brush radius (when applicable)
* \+ and - : change bpm
* left/right arrows: move bpm grid
* Y: Hold down to view local harmonic series grid
* I: show keyboard shortcuts
* ctrl+P: toggle audio preview when editing
* shift+n: toggle between selecting notes or vertices
* shift+e: toggle echo effect
* shift+r: toggle reverb effect

Drag and drop save files to open them!
Your last save file will be loaded on startup.

