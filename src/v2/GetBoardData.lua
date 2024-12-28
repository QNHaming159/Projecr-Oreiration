--================== Variables
--Main Variables
local Map_folder 	= script.Parent.Parent
local Core_folder 	= Map_folder.Core
local Floors_folder = Map_folder.Board.Floors
local Obstacles_folder = Map_folder.Board.Obstacles

local Points_folder = Core_folder.Points
local Origin = Core_folder.Origin
local Cell_size = {3.5,3.5} -- Changeable, but have to rebuild map
local Wall_thickness = 0.5

--Create Fresh Board_data
local Board_data = {
	["Grid_size"]	= {9,9}, -- Changeable, but have to expand/shrink map
	["Cells"]		= {},
	["Obstacles"]	= {["Chunks"] = {},["Walls"] = {},["Waters"] = {},["Abysses"] = {}},
	["Points"]		= {["Starts"] = {},["Ends"] = {},["Checks"] = {}}
}

--================== Functions
-- Create data for each cell
for x=1, Board_data["Grid_size"][1], 0.5 do
	Board_data["Cells"][x] = {}
	for y=1, Board_data["Grid_size"][2], 0.5 do
		Board_data["Cells"][x][y] = {}
		if (x%1~=0.5 or y%1~=0.5) then -- if a cell
			--print(x,y,":",x%1~=0.5,y%1~=0.5,"is a floor/wall")
			Board_data["Cells"][x][y] = {
				["Astar"]		= {["G"]=0,["H"]=0,["F"]=0},
				["Cord"]		= {["X"]=x,["Y"]=y},
				["Blocked"] 	= 0,
				["Visited"]		= 0,
				["Pathed"]		= 0,
			}
		else
			--print(x,y,":",x%1~=0.5,y%1~=0.5,"is a joint")
			Board_data["Cells"][x][y] = {
				["Cord"]	= {["X"]=x,["Y"]=y},
				["Blocked"] 	= 0
			}
		end
	end
end

-- Get Cord From Board
local function GetCord(part)
	local x = (part.Position.X - Origin.Position.X) / (Cell_size[1]+Wall_thickness) +1
	local y = (part.Position.Z - Origin.Position.Z) / (Cell_size[2]+Wall_thickness) +1
	return {x,y}
end

-- Place Wall around Chunk
local Wall_added = {}
local function Walls_aroundChunk(Chunk_cord)
	for _,Offset_cord in pairs {{0.5,0},{-0.5,0},{0,0.5},{0,-0.5}} do
		local Duped = false
		local New_wall_cord = {Chunk_cord[1]+Offset_cord[1],Chunk_cord[2]+Offset_cord[2]}
		if New_wall_cord[1]<1 or New_wall_cord[1]>Board_data.Grid_size[1] or New_wall_cord[2]<1 or New_wall_cord[2]>Board_data.Grid_size[2] then -- if cord is unvalid
			continue -- skip
		end
		for _,Wall in pairs(Wall_added) do
			if Wall[1]==New_wall_cord[1] and Wall[2]==New_wall_cord[2] then -- if wall already exist
				--print(New_wall_cord[1],New_wall_cord[2],"already exist")
				Duped = true
				break -- skip
			end
		end
		if not Duped then
			--print("new wall:",New_wall_cord[1],New_wall_cord[2])
			table.insert(Board_data.Obstacles.Walls,New_wall_cord)
			table.insert(Wall_added,New_wall_cord)
		end
	end
end

--Get Obstacles
for _,Obstacle in pairs(Obstacles_folder:GetChildren()) do
	local Cord = GetCord(Obstacle)
	if (Obstacle.Name=="Chunk") then
		table.insert(Board_data.Obstacles.Chunks,Cord)
		Walls_aroundChunk(Cord)
	elseif (Obstacle.Name=="Wall") then
		table.insert(Board_data.Obstacles.Walls,Cord)
	end
end

--Get Points
for _,point in pairs(Points_folder:GetChildren()) do
	local vaules = point.Name:split("_")
	if vaules[1] == "Start" then
		table.insert(Board_data.Points.Starts,vaules[2],GetCord(point))
	elseif vaules[1] == "End" then
		table.insert(Board_data.Points.Ends,vaules[2],GetCord(point))
	elseif vaules[1] == "Check" then
		table.insert(Board_data.Points.Checks,vaules[2],GetCord(point))
	end
end

----Get Floor
--for _,Cell in pairs(Floors_folder:GetChildren()) do
--	local Cord = GetCord(Cell)
--	Cell.Name = Cord[1]..","..Cord[2]
--end

--print(Board_data)
return Board_data