--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

require "BuildingObjects/ISBuildingObject"

ISMowingCursor = ISBuildingObject:derive("ISMowingCursor");

function ISMowingCursor:create(x, y, z, north, sprite)
	local playerObj = self.character
	local sq = getSquare(x, y, z);
	ISInventoryPaneContextMenu.equipWeapon(self.scythe, true, true, playerObj:getPlayerNum())
	ISTimedActionQueue.add(ISMowing:new(playerObj, self.scythe, sq, self.radius));
end

function ISMowingCursor:walkTo(x, y, z)
	local playerObj = self.character
	x,y,z = self:getTopLeftOfSquares(x, y, z)
	local squares = self:getSquares(x, y, z)
	if self.character:getJoypadBind() == -1 then
		local closestSq = self:getClosestSquare(squares)
		if playerObj:getCurrentSquare() == closestSq then
			return true
		end
		local adjacent = AdjacentFreeTileFinder.Find(closestSq, self.character)
		if not adjacent then return false end
		ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, adjacent))
	end
	return true
end

function ISMowingCursor:isValid(square)
	local x,y,z = self:getTopLeftOfSquares(square:getX(), square:getY(), square:getZ())
	return self:isValidArea(x, y, z)
end

function ISMowingCursor:isValidArea(x, y, z)
	local squares = self:getSquares(x, y, z)
	local hasGrass = false;
	for _,square2 in ipairs(squares) do
		if not square2:isCouldSee(self.character:getPlayerNum()) then
			return false;
		end
		if square2:checkHaveGrass() then
			hasGrass = true;
		end
	end
	return hasGrass
end

function ISMowingCursor:isRunningAction()
    local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.character);
    return actionQueue and actionQueue.queue and actionQueue.queue[1]
end

function ISMowingCursor:getTopLeftOfSquares(x, y, z)
	if self.character:getJoypadBind() ~= -1 then
		local cx,cy = math.floor(self.character:getX()), math.floor(self.character:getY())
		if self.character:isOnFire() then
			return cx,cy,z
		end
		local dir = self.character:getDir()
		if     dir == IsoDirections.N  then   x,y = cx,   cy-2
		elseif dir == IsoDirections.NE then   x,y = cx+1, cy-2
		elseif dir == IsoDirections.E  then   x,y = cx+1, cy
		elseif dir == IsoDirections.SE then   x,y = cx+1, cy+1
		elseif dir == IsoDirections.S  then   x,y = cx,   cy+1
		elseif dir == IsoDirections.SW then   x,y = cx-2, cy+1
		elseif dir == IsoDirections.W  then   x,y = cx-2, cy
		elseif dir == IsoDirections.NW then   x,y = cx-2, cy-2
		end
	end
	return x,y,z
end

function ISMowingCursor:render(x, y, z, square)
	if self:isRunningAction() then return end
	x,y,z = self:getTopLeftOfSquares(x, y, z)
	local bValid = self:isValidArea(x, y, z)
	if bValid then
		renderIsoRect(x + 1, y + 1, z, self.radius, getCore():getGoodHighlitedColor():getR(),getCore():getGoodHighlitedColor():getG(),getCore():getGoodHighlitedColor():getB(), 0.5, 1)
	else
		renderIsoRect(x + 1, y + 1, z, self.radius, getCore():getBadHighlitedColor():getR(),getCore():getBadHighlitedColor():getG(),getCore():getBadHighlitedColor():getB(), 0.5, 1)
	end
	
	if self.character:getJoypadBind() ~= -1 then return end
	
end

function ISMowingCursor:onJoypadPressButton(joypadIndex, joypadData, button)
	if button == Joypad.AButton or button == Joypad.BButton then
		return ISBuildingObject.onJoypadPressButton(self, joypadIndex, joypadData, button)
	end
end

function ISMowingCursor:getAPrompt()
	return getText("ContextMenu_MowGrass")
end

function ISMowingCursor:getLBPrompt()
	return nil
end

function ISMowingCursor:getRBPrompt()
	return nil
end

function ISMowingCursor:getSquares(x, y, z)
	local squares = {}
	local square = getCell():getGridSquare(x, y, z)
	table.insert(squares, square)
	for x2=x,x+self.radius-1 do
		for y2=y,y+self.radius-1 do
			local square = getCell():getGridSquare(x2, y2, z)
			if square then
				table.insert(squares, square)
			end
		end
	end
	return squares
end

function ISMowingCursor:getClosestSquare(squares)
	local closest = nil
	local closestDist = 1000000
	for _,square2 in ipairs(squares) do
		local dist = IsoUtils.DistanceTo(self.character:getX(), self.character:getY(), square2:getX() + 0.5, square2:getY() + 0.5)
		if dist < closestDist then
			closest = square2
			closestDist = dist
		end
	end
	return closest
end

function ISMowingCursor:getGrassObject(square)
	local objects = {}
	for i=1,square:getObjects():size() do
		local object = square:getObjects():get(i-1)
		if instanceof(object, "IsoFire") and not object:isPermanent() then
			table.insert(objects, object)
		end
	end
	return objects
end

function ISMowingCursor:rotateKey(key)
	if getCore():isKey("Rotate building", key) then
		self.radius = self.radius - 1;
		if self.radius == 0 then
			self.radius = self.maxRadius;
		end
	end
end

function ISMowingCursor:new(character, scythe)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o:init()
	o.character = character
	o.player = character:getPlayerNum()
	o.skipBuildAction = true
	o.noNeedHammer = true
	o.skipWalk = true
	o.renderFloorHelper = true
	o.scythe = scythe
	o.radius = 3;
	o.maxRadius = 3;
	if scythe:getType() == "HandScythe" or scythe:hasTag("HandScythe") then
		o.radius = 1;
		o.maxRadius = 1;
	end
	return o
end

Events.OnKeyPressed.Add(rotateKey);
