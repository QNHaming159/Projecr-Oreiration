--Get Data
local MapData = require(script.Parent.Data)
--Initialize OpenList and ClosedList
local Open_list = {}
--Add the StartNode on the OpenList
table.insert(Open_list,MapData["Cells"][MapData["Start"][1]][MapData["Start"][2]])

--Run the AStar algorithm
local Path = {}
while #Open_list>0 do
	--Get the current node with least F
	Current_Node = Open_list[1]
	Current_Index = 1
	
	-- Get lowest F and H
	for i=1,#Open_list do
		if Open_list[i]["F"]<=Current_Node["F"] and Open_list[i]["H"]<=Current_Node["H"] then
			Current_Node = Open_list[i]
			Current_Index = i
		end
	end
	MapData["Cells"][Current_Node["X"]][Current_Node["Y"]]["V"] = 1
	table.remove(Open_list,Current_Index)
	
	--TEST
	local part = script.Parent.Parent._Floor:FindFirstChild(Current_Node["X"]..","..Current_Node["Y"])
	part.Color = Color3.fromRGB(106,57,9)
	--*-------------
	
	-- Found the goal
	if Current_Node == MapData["Cells"][MapData["End"][1]][MapData["End"][2]] then
		print("Goal found")
		Path = {Current_Node}
		Current_Node["V"] = 0
		local Lowest_F = Current_Node["F"]
		local Lowest_G =  Current_Node["G"]
		while Current_Node ~= MapData["Cells"][MapData["Start"][1]][MapData["Start"][2]] do
			for _,New_Position in pairs {{0,1},{0,-1},{1,0},{-1,0}} do -- Check cells in 4 directions
				-- Get New_Node Position
				local Node_Position = {Current_Node["X"]+New_Position[1],Current_Node["Y"]+New_Position[2]}
				-- Check if New_Node is valid
				if Node_Position[1]<1 or Node_Position[1]>MapData["Grid"][1] or Node_Position[2]<1 or Node_Position[2]>MapData["Grid"][2] then
					continue
				end
				-- Check if New_Node is blocked
				if MapData["Cells"][Node_Position[1]][Node_Position[2]]["B"]==1 then
					continue
				end
				-- Check if New_node is not visited
				if MapData["Cells"][Node_Position[1]][Node_Position[2]]["V"]==0 then
					continue
				end
				-- Check lowest F
				if MapData["Cells"][Node_Position[1]][Node_Position[2]]["F"]<Lowest_F or MapData["Cells"][Node_Position[1]][Node_Position[2]]["G"]<=Lowest_G then
					Lowest_F = MapData["Cells"][Node_Position[1]][Node_Position[2]]["F"]
					Lowest_G = MapData["Cells"][Node_Position[1]][Node_Position[2]]["G"]
					MapData["Cells"][Node_Position[1]][Node_Position[2]]["V"] = 0
					Current_Node = MapData["Cells"][Node_Position[1]][Node_Position[2]]
					table.insert(Path,Current_Node)
					local part = script.Parent.Parent._Floor:FindFirstChild(Node_Position[1]..","..Node_Position[2])
					part.Color = Color3.fromRGB(18,238,212)
					break
				end
			end
		end
		break
	end
	
	New_Nodes = {}
	for _,New_Position in pairs {{0,1},{0,-1},{1,0},{-1,0}} do -- Check cells in 4 directions
		-- Get New_Node Position
		local Node_Position = {Current_Node["X"]+New_Position[1],Current_Node["Y"]+New_Position[2]}
		-- Check if New_Node is valid
		if Node_Position[1]<1 or Node_Position[1]>MapData["Grid"][1] or Node_Position[2]<1 or Node_Position[2]>MapData["Grid"][2] then
			continue
		end
		-- Check if New_Node is blocked
		if MapData["Cells"][Node_Position[1]][Node_Position[2]]["B"]==1 then
			continue
		end
		-- Check if New_node is visited
		if MapData["Cells"][Node_Position[1]][Node_Position[2]]["V"]==1 then
			continue
		end
		-- Check if New_node in Open_List
		local Duped = false
		for _,Node in pairs(Open_list) do
			if Node["X"]==Node_Position[1] and Node["Y"]==Node_Position[2] then
				--print("This node has already in waiting list")
				Duped = true
				break
			end
		end
		if Duped==false then
			table.insert(New_Nodes,MapData["Cells"][Node_Position[1]][Node_Position[2]])
		end
	end
	for _,Node in pairs(New_Nodes) do
		-- Create the F, G, H values
		Node["G"] = Current_Node["G"]+1
		Node["H"] = math.abs(Node["X"]-MapData["End"][1])+math.abs(Node["Y"]-MapData["End"][2])
		Node["F"] = Node["G"]+Node["H"]
		-- Add Node to Open_List
		table.insert(Open_list,Node)
		
		--TEST
		local part = script.Parent.Parent._Floor:FindFirstChild(Node["X"]..","..Node["Y"])
		part.Color = Color3.fromRGB(255,255,0)
		--*-------------
	end
end