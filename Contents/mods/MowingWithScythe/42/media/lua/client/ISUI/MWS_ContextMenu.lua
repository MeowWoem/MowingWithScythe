--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

local ContextMenu = {}


local function predicateScythe(item)
	return not item:isBroken() and item:hasTag("Scythe")
end

function ContextMenu.onMowGrass(player, scythe)
	local bo = ISMowingCursor:new(player, scythe)
	getCell():setDrag(bo, bo.player)
end

function ContextMenu.addMowContextOption(player, context, worldObjects, test)
	local playerObj = getSpecificPlayer(player)
	local playerInv = playerObj:getInventory()
	if playerObj:isAsleep() then return end
	local scythe = playerInv:getFirstEvalRecurse(predicateScythe);
	if scythe and not playerObj:getVehicle() then
		if test == true then return true; end
		context:addGetUpOption(getText("ContextMenu_MowGrass"), playerObj, ContextMenu.onMowGrass, scythe);
	end
end

Events.OnFillWorldObjectContextMenu.Add(ContextMenu.addMowContextOption)

return ContextMenu