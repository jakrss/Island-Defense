//! zinc
library TurtleInventory {
    private struct TurtleInventory {
        private static method onInit(){
            trigger t = CreateTrigger();
            
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_PICKUP_ITEM);
            TriggerAddCondition(t, Condition(function() -> boolean {
                item it = GetManipulatedItem();
                if (GetUnitAbilityLevel(GetTriggerUnit(), 'A014') > 0){ // Has turtle inventory
                    SetItemPawnable(it, false);
                }
                it = null;
                return false;
            }));
            t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DROP_ITEM);
            TriggerAddCondition(t, Condition(function() -> boolean {
                item it = GetManipulatedItem();
                if (GetUnitAbilityLevel(GetTriggerUnit(), 'A014') > 0){ // Has turtle inventory
                    SetItemPawnable(it, IsItemIdPawnable(GetItemTypeId(it)));
                }
                it = null;
                return false;
            }));
            t = null;
        }
    }
}

//! endzinc