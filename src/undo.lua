Undo = {}

Undo.maxSize = 50

function Undo.load()
	Undo.stack = {}
	Undo.index = 0
	Undo.register()
end

function Undo.register()
	Undo.index = Undo.index + 1
	for i = #Undo.stack, Undo.index, -1 do
		Undo.stack[i] = nil
	end
	local t = {}
	t.song = deepcopy(song)
	t.selection = Selection.getIndices()
	Undo.stack[Undo.index] = t

	if #Undo.stack > Undo.maxSize then
		table.remove(Undo.stack,1)
		Undo.index = Undo.index - 1
	end
end

function Undo.undo()
	Undo.index = Undo.index - 1
	if Undo.index >= 1 then
		song = deepcopy(Undo.stack[Undo.index].song)
		Selection.setFromIndices(Undo.stack[Undo.index].selection)
	else
		Undo.index = 1
		print("nothing to undo!")
	end
end

function Undo.redo()
	Undo.index = Undo.index + 1
	if Undo.stack[Undo.index] then
		song = deepcopy(Undo.stack[Undo.index].song)
		Selection.setFromIndices(Undo.stack[Undo.index].selection)
	else
		Undo.index = #Undo.stack
		print("nothing to redo!")
	end
end

-- deepcopy with recursive tables.
function deepcopy(orig, copies)
	copies = copies or {}
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		if copies[orig] then
			copy = copies[orig]
		else
			copy = {}
			copies[orig] = copy
			for orig_key, orig_value in next, orig, nil do
				copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
			end
			setmetatable(copy, deepcopy(getmetatable(orig), copies))
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end
