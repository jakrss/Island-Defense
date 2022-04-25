//! zinc
library ItemExtras requires Event {
    // Basic Item
    private Event OnAcquireItem;
    private Event OnLoseItem;
    
    public function onAcquireItem(trigger which) {
        OnAcquireItem.register(which);
    }
    
    public function onLoseItem(trigger which) {
        OnLoseItem.register(which);
    }
    
    public function GetFreeSlots(unit u) -> integer {
        integer slot = 0;
        item tempItem;
        integer count = 0;
        for(0 <= slot <= 5) {
            tempItem = UnitItemInSlot(u, slot);
            if(tempItem == null) count = count + 1;
        }
        return count;
    }
    
    public function GetSlotById(unit u, integer itemId) -> integer {
        integer slot=0;
        item tempItem;
        //Looping through the slots
        for(0 <= slot <= 5) {
            tempItem = UnitItemInSlot(u, slot);
            if(GetItemTypeId(tempItem) == itemId) return slot;
        }
        return -1;
    }
    
    //Will only return first occurance found
    public function GetItemFromUnitById(unit u, integer itemId) -> item {
        integer slot = GetSlotById(u, itemId);
        if(slot >= 0) return UnitItemInSlot(u, slot);
        return null;
    }

    public function GetItemCountFromUnitById(unit u, integer itemId) -> integer {
	integer slot = 0;
        integer count = 0;
	item tempItem;
	//Loop through the slots
	for(0 <= slot <= 5) {
	    tempItem = UnitItemInSlot(u, slot);
	    if(GetItemTypeId(tempItem) == itemId) {
	        count = count + 1;
	    }
            tempItem = null;
	}
	return count;
    }
    
    public function GetItemCountFromUnit(unit u, item checkItem) -> integer {
        integer slot = 0;
        integer count = 0;
        item tempItem;
        //Loop through the slots
        for(0 <= slot <= 5) {
            tempItem = UnitItemInSlot(u, slot);
            if(tempItem == checkItem) {
                count = count + 1;
            }
        }
        return count;
    }
    
    public function UnitHasItemById(unit u, integer itemId) -> boolean {
        return GetSlotById(u, itemId) >= 0;
    }
    
    //NOT POSSIBLE TO KEEP COOLDOWNS - ONLY FIRST TWO OCCURANCES
    public function ReplaceItemById(unit u, integer replaceId, integer newItemId) -> item {
        item tempItem = GetItemFromUnitById(u, replaceId);
        integer slot = GetSlotById(u, replaceId);
        UnitRemoveItem(u, tempItem);
        UnitAddItemToSlotById(u, newItemId, slot);
        return UnitItemInSlot(u, slot);
    }
    
    private function Setup() {        
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_PICKUP_ITEM);
        TriggerAddCondition(t, Condition(function()->boolean {
            OnAcquireItem.fire();
            return false;
        }));
        t=null;
        t=CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DROP_ITEM);
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_PAWN_ITEM);
        TriggerAddCondition(t, Condition(function()->boolean {
            OnLoseItem.fire();
            return false;
        }));
        t=null;
    }
    
    private function onInit() {
        OnAcquireItem = Event.create();
        OnLoseItem = Event.create();
        Setup();
    }

}
//! endzinc