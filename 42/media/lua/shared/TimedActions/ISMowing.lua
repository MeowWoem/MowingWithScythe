--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISMowing = ISBaseTimedAction:derive("ISMowing");

function ISMowing:isValid()
    return true;
end

function ISMowing:update()
   	self.item:setJobDelta(self:getJobDelta());
    self.character:setMetabolicTarget(Metabolics.HeavyWork);
end

function ISMowing:start()
    self.item:setJobType(getText("ContextMenu_MowGrass"));
 	self.item:setJobDelta(0.0);

    self:setActionAnim("scything")
    self:setOverrideHandModels(self.item, nil)

    self.sound = self.character:playSound("ScytheGrass")
end

function ISMowing:stop()
    self:stopSound()
    self.item:setJobDelta(0.0);

    ISBaseTimedAction.stop(self);
end

function ISMowing:perform()
    self:stopSound()
    self.item:setJobDelta(0.0);

    ISBaseTimedAction.perform(self);
end

function ISMowing:complete()
    for x=self.sq:getX(), self.sq:getX()+self.radius-1 do
        for y=self.sq:getY(), self.sq:getY()+self.radius-1 do
            local sq = getSquare(x, y, self.sq:getZ());
            if sq then
                self:getGrass(sq);
            end
        end
    end
    return true
end

function ISMowing:getGrass(sq)
	for i=sq:getObjects():size(),1,-1 do
		local object = sq:getObjects():get(i-1)
		if object:getProperties() and object:getProperties():Is(IsoFlagType.canBeRemoved) then
			sq:transmitRemoveItemFromSquare(object)
			local items = self.character:getInventory():AddItems("Base.GrassTuft", ZombRand(2,4));
			sendAddItemsToContainer(self.character:getInventory(), items);
		end
	end
end

function ISMowing:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end
	local duration = 0;
	for x=self.sq:getX(), self.sq:getX()+self.radius-1 do
        for y=self.sq:getY(), self.sq:getY()+self.radius-1 do
            local sq = getSquare(x, y, self.sq:getZ());
            if sq then
                for i=sq:getObjects():size(),1,-1 do
					local object = sq:getObjects():get(i-1)
					if object:getProperties() and object:getProperties():Is(IsoFlagType.canBeRemoved) then
						duration = duration + 20;
					end
				end
            end
        end
    end
    return duration
end

function ISMowing:stopSound()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:stopOrTriggerSound(self.sound);
    end
end

function ISMowing:new (character, item, sq, radius)
    local o = ISBaseTimedAction.new(self, character)
    
    o.item = item;
    if item and not radius then
        radius = 3
        if item:getType() == "HandScythe" or item:hasTag("HandScythe") then
           radius = 1
        end
    end
    o.radius = radius;
    o.sq = sq or character:getCurrentSquare();
	o.maxTime = o:getDuration();
    return o
end


