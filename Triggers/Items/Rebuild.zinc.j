// Coded by Neco for Island Defense
// God this is one sexy piece of code.
// SEXIIIIIIIIIIEEEEHHHH

//! zinc
library RebuildItemSystem {
    function GetTransmutedItemId(item it) -> integer {
        integer id = GetItemTypeId(it);
    //============= ITEM -> REBUILD ============
        if (id == 'I04L'){return 'I04M';}  // Tavern
        if (id == 'I04J') {return 'I04K';} // Fireworks
        if (id == 'I01K') {return 'I04U';} // Mutation
        if (id == 'I038') {return 'I04T';} // Replicator
        if (id == 'I05T') {return 'I05U';} // Egg Sack
        if (id == 'I014') {return 'I03K';} // Spell Well
	if (id == 'I08D') {return 'I08C';} // Super Keg
    //============= REBUILD -> ITEM ============
        if (id == 'I04M') {return 'I04L';} // Tavern  
        if (id == 'I04K') {return 'I04J';} // Fireworks  
        if (id == 'I04U') {return 'I01K';} // Mutation 
        if (id == 'I04T') {return 'I038';} // Replicator 
        if (id == 'I05U') {return 'I05T';} // Egg Sack
        if (id == 'I03K') {return 'I014';} // Spell Well
	if (id == 'I08C') {return 'I08D';} // Super Keg
        return 0;
    }
    
    function onAct() {
        item it = GetOrderTargetItem();
        item it2 = null;
        integer i = GetItemCharges(it);
        integer j = 0;
        integer slotid = GetIssuedOrderId()-852002;
        unit u = GetOrderedUnit();
        integer id = GetTransmutedItemId(it);
        
        it2 = UnitItemInSlot(u, slotid);
        if (it == it2 && id != 0){
            RemoveItem(it);
            DisableTrigger(RecipeSYS_TRIGGER);
            UnitAddItemToSlotById(u, id, slotid);
            EnableTrigger(RecipeSYS_TRIGGER);
        }
        
        // ALSO HANDLE STACKED ITEMS HERE (terrible, I know)
        else if (GetItemType(it) == ITEM_TYPE_CHARGED && it == it2) {
            // Split
            // i = 5
            if (i > 1) {
                j = i / 2; // i = 5, j = 2
                j = i - j; // i = 5, j = 3
                i = i - j; // i = 2, j = 3
                SetItemCharges(it, i);
                it = CreateItem(GetItemTypeId(it), GetUnitX(u), GetUnitY(u));
                DisableTrigger(RecipeSYS_TRIGGER);
                UnitAddItem(u, it);
                EnableTrigger(RecipeSYS_TRIGGER);
                SetItemCharges(it, j);
            }
        }
        // Merge
        else if (GetItemType(it) == ITEM_TYPE_CHARGED && GetItemTypeId(it) == GetItemTypeId(it2)) {
            SetItemCharges(it, GetItemCharges(it2) + i);
            RemoveItem(it2);
        }
        
        it = null;
        it2 = null;
        u = null;
    }
    
    function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER );
        TriggerAddCondition(t, function()->boolean {
            return (GetIssuedOrderId() > 852001 && GetIssuedOrderId() < 852008);
        });
        TriggerAddAction( t, function onAct );
    }
}
//! endzinc