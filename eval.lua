local clickDetector = workspace.table.Execute.ClickDetector

function onMouseClick()
	if workspace.table.Ready.BrickColor ~= BrickColor.new("Lime green") then
		--print("success")
		return
	end
	local starting = tick()
	--print("begin", starting) 
	local display = workspace.sols.solution.Solution.SurfaceGui.TextLabel
	if not workspace:FindFirstChild("Head") then
		display.Text = "nil"
		return
	elseif workspace.Head.SurfaceGui.TextLabel.Text == "nil" then
		display.Text = "nil"
		return
	end
	local head = workspace.Head
	local t = {}
	local stack = {}
	table.insert(stack, head)
	--print(table.getn(stack))
	while table.getn(stack) ~= 0 do
		--print(stack)
		local temp = table.remove(stack, 1)
		table.insert(t, temp.SurfaceGui.TextLabel.Text)
		if not string.match(temp.SurfaceGui.TextLabel.Text, "%d") then
			table.insert(stack, 1, temp.Child2)
			table.insert(stack, 1, temp.Child1)
		end
		
	end

	--local t = {"+","*",5,2,"^",3,4}

	--print(#t)

	for i in pairs(t) do
		if string.match(t[i], "%d") then
			t[i] = tonumber(t[i])
		end
	end

	local cur = 1
	while #t > 1 do
		if t[cur] == "+" then
			if typeof(t[cur+1]) == "number" and typeof(t[cur+2]) == "number" then
				t[cur] = t[cur+1] + t[cur+2]
				table.remove(t,cur+2)
				table.remove(t,cur+1)
				cur -= 2
			end
		elseif t[cur] == "-" then
			if typeof(t[cur+1]) == "number" and typeof(t[cur+2]) == "number" then
				t[cur] = t[cur+1] - t[cur+2]
				table.remove(t,cur+2)
				table.remove(t,cur+1)
				cur -= 2
			end
		elseif t[cur] == "*" then
			if typeof(t[cur+1]) == "number" and typeof(t[cur+2]) == "number" then
				t[cur] = t[cur+1] * t[cur+2]
				table.remove(t,cur+2)
				table.remove(t,cur+1)
				cur -= 2
			end
		elseif t[cur] == "/" then
			if typeof(t[cur+1]) == "number" and typeof(t[cur+2]) == "number" then
				t[cur] = t[cur+1] / t[cur+2]
				table.remove(t,cur+2)
				table.remove(t,cur+1)
				cur -= 2
			end
		elseif t[cur] == "^" then
			if typeof(t[cur+1]) == "number" and typeof(t[cur+2]) == "number" then
				t[cur] = t[cur+1] ^ t[cur+2]
				table.remove(t,cur+2)
				table.remove(t,cur+1)
				cur -= 2
			end
		end
		
		
		
		cur += 1
		if(cur >= #t) then
			cur = 1
		end
	end

	--print(t[1])
	--local display = workspace.Solution
	display.Text = t[1]
	--if string.len(t[1]) > 10 then
	--	display.TextSize = 100 - string.len(t[1])*3
	--else
	--	display.TextSize = 100
	--end
	--print("calculation time", tick() - starting)
	
	local dec_places = 10 -- the amount of decimal places
	local exe_time = tick() - starting

	exe_time = math.floor(exe_time*10^dec_places)/10^dec_places 
	workspace.sols.time.Solution.SurfaceGui.TextLabel.Text = exe_time
end

clickDetector.MouseClick:connect(onMouseClick)
