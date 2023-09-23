exclude_files = { "**/lib/*.lua" }

std = "max+justidaw+love"
stds.love = {
   globals = { "love" },
}
stds.justidaw = {
   globals = {
      "song",
      "mouseX",
      "mouseY",
      "mousePX",
      "mousePY",
      "modifierKeys",
      "mouseDown",
      "width",
      "height",
      "pres",
      "minLength",
      "automergeDist",
      "selectNotes",
      "currentTool",
      "selectedTool",
      "preview",
      "tabletInput",
      "textInput",

      -- functions
      "setMessage",
      "selectTool",
      "setTool",
      "mousepressed",
      "mousereleased",
      "deepcopy",

      -- modules
      "File",
      "Clipboard",
      "View",
      "Audio",
      "Edit",
      "Selection",
      "Tablet",
      "Undo",
      "Theme",
   },
   read_globals = { "VERSION_MAJOR", "VERSION_MINOR" },
}

ignore = {
   "212", -- unused function arg
   "213", -- unused loop variable
   "561", -- cyclomatic complexity
}

-- allow_defined_top = true
