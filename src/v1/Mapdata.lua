--================== Variables
--Main Variables
local Core_Folder = script.Parent
local Cell_Folder = script.Parent.Parent.Cell
local Points_Folder = Core_Folder.Points

local Cell_Size = {4,4} -- Changeable, but have to rebuild map
local Origin = Core_Folder.Origin

--Create Fresh MapData
local MapData = {
	Grid	= {10,10}, -- Changeable, but have to expand/shrink map
	Cells	= {},
	Starts	= {},
	Ends	= {},
	Checks	= {}
}

-- Create data for each node
for x=1, MapData["Grid"][1] do
	MapData["Cells"][x] = {}
	for y=1, MapData["Grid"][2] do
		MapData["Cells"][x][y] = {
			["X"]=x,["Y"]=y,
			["G"]=0,["H"]=0,["F"]=0,
			["_isModify"]={},
		}
	end
end

--================== Functions
--Get Cord From Cell
local function GetCord(part)
	local x = (part.Position.X - Origin.Position.X) / Cell_Size[1] +1
	local y = (part.Position.Z - Origin.Position.Z) / Cell_Size[2] +1
	return {x,y}
end

-- Get Cliff cells
for _,Cell in pairs(Cell_Folder:GetChildren()) do
	local Cord = {}
	Cord = GetCord(Cell)
	Cell.Name = Cord[1]..","..Cord[2]
	MapData["Cells"][Cord[1]][Cord[2]]["_Blocked"] = 1 -- "Blocked"
end

-- Get Starts, Ends, Checks Points
for _,point in pairs(Points_Folder:GetChildren()) do
	local vaules = point.Name:split("_")
	if vaules[1] == "Start" then
		table.insert(MapData["Starts"],vaules[2],GetCord(point))
	elseif vaules[1] == "End" then
		table.insert(MapData["Ends"],vaules[2],GetCord(point))
	elseif vaules[1] == "Check" then
		table.insert(MapData["Checks"],vaules[2],GetCord(point))
	end
end


--MapData["Start"] = GetCord(CoreData["Start"])
--MapData["End"] = GetCord(CoreData["End"])

--DEBUG
--for _,CELL in pairs(script.Parent.Parent._Floor:GetChildren()) do
--	local Cord = {}
--	Cord = GetCord(CELL)
--	CELL.Name = Cord[1]..","..Cord[2]
--end


return MapData