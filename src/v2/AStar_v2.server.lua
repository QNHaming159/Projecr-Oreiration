--================== Settings
local Debug = false -- default false
local Start_index,End_index = 1,1 -- default 1,1

--================== Variables
--Main Variables
local Board_data = require(script.Parent.GetBoardData)
local Open_list = {}

local Start_cord = Board_data.Points.Starts[Start_index]
local End_cord = Board_data.Points.Ends[End_index]

table.insert(Open_list,Start_cord)

--================== Helper Functions
local function CheckSurround_isValid(Node_cord,Visited_choice)
	-- Check if New_Node is valid
	if Node_cord[1]<1 or Node_cord[1]>Board_data.Grid_size[1] or Node_cord[2]<1 or Node_cord[2]>Board_data.Grid_size[2] then
		return false
	end
	-- Check if New_Node is blocked
	if Board_data.Cells[Node_cord[1]][Node_cord[2]].Blocked==1 then
		return false
	end
	-- Check if New_node is visited
	if Board_data.Cells[Node_cord[1]][Node_cord[2]].Visited==Visited_choice then
		return false
	end
	return true
end

local function CordtoNode(Cord)
	return Board_data.Cells[Cord[1][Cord[2]]]
end

--================== A Star Functions
while #Open_list>0 do
	--============== Ready Phase
	-- Get a node
	local Current_cord = Open_list[1]
	local Current_node = CordtoNode(Current_cord)
	-- Get lowest F and H score in open list
	for i,Node in pairs(Open_list) do
		if Node.F <= Current_node.F and Node.H <= Current_node.H then
			Current_node = Open_list[i]
		end
	end
	-- Remove sellected node from open list
	table.remove(Open_list,table.find(Open_list,Current_node))
	
	--============== Goal Phase
	-- If current node is the goal then return the path
	if Current_cord == End_cord then
		local Path = {Current_cord}
		local Lowest_F,Lowest_G = Current_cord.Astar.F,Current_cord.Astar.G
		while Current_cord ~= Start_cord do
			for _,Offset_cord in pairs {{0,1},{0,-1},{1,0},{-1,0}} do -- Check cells in 4 directions
				local New_cord = {Current_cord[1]+Offset_cord[1],Current_cord[2]+Offset_cord[2]}
				if CheckSurround_isValid(New_cord,false) then continue end -- If cord is unvalid
				local Get_node = Board_data.Cells[New_cord[1]][New_cord[2]] -- Get node
				-- Get lowest F or lowest G score
				local Get_F,Get_G = Get_node.Astar.F, Get_node.Astar.G
				if Lowest_F >= Get_F and Lowest_G >= Get_G then Lowest_F,Lowest_G = Get_F,Get_G end
				Get_node.Visited = 0 -- Remove "visited" mark
				-- Add node to path and continue to next move 
				table.insert(Path,Get_node)
				Current_cord = New_cord
			end
		end
	end
	
	--============== Expand Phase
	-- Mark "visited" to the sellected node
	CordtoNode(Current_cord).Visited = 1
	-- If not then check the next move is valid
	local New_nodes = {}
	for _,Offset_cord in pairs {{0,1},{0,-1},{1,0},{-1,0}} do -- Check cells in 4 directions
		local New_cord = {Current_cord[1]+Offset_cord[1],Current_cord[2]+Offset_cord[2]}
		if CheckSurround_isValid(New_cord,true) then continue end -- If new cord is unvalid
		if table.find(Open_list,New_cord) then continue end -- Check if this new cord is in open list
		table.insert(New_nodes,Board_data.Cells[New_cord[1]][New_cord[2]]) -- Add new node to the list
	end
	-- Get A star scores for new nodes
	for _,Node in pairs(New_nodes) do
		-- Create the F, G, H values for node
		Node.Astar.G = New_nodes.Astar.G+1
		Node.Astar.H = math.abs(Node.X-End_cord[1])+math.abs(Node.Y-End_cord[2])
		Node.Astar.F = Node.Astar.G+Node.Astar.H
		-- Add node to Open_List
		table.insert(Open_list,Node)
	end
	--============== Debug Phase
end