local example = workspace.Example
local clickDetector = script.Parent.ClickDetector

function onMouseClick()
	workspace.table.Execute.ClickDetector.MaxActivationDistance = 0
	workspace.table.Clear.ClickDetector.MaxActivationDistance = 0
	workspace.table.Ready.BrickColor = BrickColor.new(255, 0, 0)
	if workspace:FindFirstChild("Head") then
		local head = workspace.Head
		head:Destroy()
	end
	local stack = order()
	--print("before print", stack)
	local part = example:Clone()
	part.Name = "Head"
	part.Parent = workspace
	
	local depth = depth(stack) - 2
	--print(depth)
	local height = 14
	if depth > 2 then
		height = height + depth*2 - 2*2
	end

	--print(stack)
	
	local label = part.SurfaceGui.TextLabel
	
	if type(stack) == "table" then
		if stack[1] == nil then
			stack = "nil"
			label.Text = "nil"
		else
			label.Text = stack[2]
		end
	else
		label.Text = stack
	end
	
	--print("depth", depth)
	local helper = 0
	if depth == 2 then
		helper = depth - 1
	elseif depth == 3 then
		helper = depth
	elseif depth > 3 then
		helper = depth + 2
	end
	
	part.Position = example.Position + Vector3.new(0, height, -helper) -- leave z unchanged. boxes are 2x2x2
	
	if type(stack) == "table" then
		createAST(stack[1], -1 - depth - helper, height - 2, part, "Child1", 2, depth+2, -helper)
		createAST(stack[3], 1 + depth + helper, height - 2, part, "Child2", 2, depth+2, -helper)
	end
	print("AST CREATED")
	workspace.table.Ready.BrickColor = BrickColor.new(0, 255, 0)
	workspace.table.Execute.ClickDetector.MaxActivationDistance = 32
	workspace.table.Clear.ClickDetector.MaxActivationDistance = 32
	-- time: https://devforum.roblox.com/t/get-script-execution-time/1419805
end

function depth(stack)
	if type(stack) == "table" then
		local a = depth(stack[1])
		local b = depth(stack[3])
		local max = a
		if a < b then
			max = b
		end
		return max + 1
	else
		return 1
	end
end

function createAST(val, xloc, yloc, parent, name, curDepth, maxDepth, out)
	local delayy = workspace.table.Delay.SurfaceGui.TextLabel.Text
	wait(delayy)
	local key = ""
	if type(val) == "table" then
		key = val[2]
	else
		key = val
	end
	local part = example:Clone()
	part.Name = name
	part.Parent = parent
	part.Position = example.Position + Vector3.new(xloc, yloc, out) -- leave z unchanged. boxes are 2x2x2
	part.SurfaceGui.TextLabel.Text = key
	--print("depth test:", curDepth-maxDepth)
	if type(val) == "table" then
		createAST(val[1], xloc+curDepth-maxDepth, yloc-2, part, "Child1", curDepth+1, maxDepth, out)
		createAST(val[3], xloc-curDepth+maxDepth, yloc-2, part, "Child2", curDepth+1, maxDepth, out)
	end
end

clickDetector.MouseClick:connect(onMouseClick)

function order()
	local text = workspace.expression.Enter.SurfaceGui.TextLabel.Text
	text = text:gsub(" ","") -- ignore spaces!
	print(text)
	local stack = {}
	local loop = true
	local init = 1
	local start = 1
	local finish = 1
	local cur = ""
	while loop do
		--print("loop at index:", init, "value", stack)
		
		-- FIXED bug: addition always checked first. need to make priority over first element in line instead.
		
		start, finish = string.find(text, "%d+", init)
		--print("text", text, "start", start, "finish", finish)
		if start then
			cur = string.sub(text, start, finish)
			table.insert(stack, cur)
			init = finish + 1
		else 
			break
		end
		start, finish = string.find(text, "%+", init)
		if start == init then
			table.insert(stack, "+")
			init = finish + 1
			continue
		end
		start, finish = string.find(text, "%-", init)
		if start == init then
			table.insert(stack, "-")
			init = finish + 1
			continue
		end
		start, finish = string.find(text, "%*", init)
		if start == init then
			table.insert(stack, "*")
			init = finish + 1
			continue
		end
		start, finish = string.find(text, "x", init)
		if start == init then
			table.insert(stack, "*")
			init = finish + 1
			continue
		end
		start, finish = string.find(text, "/", init)
		if start == init then
			table.insert(stack, "/")
			init = finish + 1
			continue
		end
		start, finish = string.find(text, "%^", init)
		if start == init then
			table.insert(stack, "^")
			init = finish + 1
			continue
		else
			break
		end
	end
	--print("initial change", stack)
	if table.getn(stack) == 1 then
		--local order = ""
		--order = tostring(stack[1])
		return stack[1]
	end
	local order = ast(stack)
	--print(order)
	return order
end

function ast(stack)
	--print("AST", stack)
	local order = {}
	local temp = {}	
	local done = false
	local iter = 1
	local checks = {"+", "-", "*", "/", "^"}
	while not done do
		if iter == 1000 then --safety measure
			break
		end
		local cur = checks[iter]
		for i in ipairs(stack) do
			if stack[i] == cur then
				done = true
				table.move(stack, 1, i - 1, 1, temp)
				if table.getn(temp) == 1 then
					table.insert(order, temp[1])
				else
					table.insert(order, ast(temp))
				end
				table.clear(temp)
				--print("table after move", stack)
				table.insert(order, stack[i])
				table.move(stack, i+1, table.getn(stack), 1, temp)
				--print("temp", temp)
				if table.getn(temp) == 1 then
					table.insert(order, temp[1])
				else
					table.insert(order, ast(temp))
				end
				break
			end
		end
		iter = iter + 1
	end
	return order
end
