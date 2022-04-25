//! zinc
library HunterInventory {
    private struct HunterInventory {
        private static method onInit(){
            trigger t = CreateTrigger();
            
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_PICKUP_ITEM);
            TriggerAddCondition(t, Condition(function() -> boolean {
                item it = GetManipulatedItem();
                if (GetUnitAbilityLevel(GetTriggerUnit(), 'A04A') > 0){ // Has Hunter inventory
                    SetItemDropOnDeath(it, false);
                }
                else {
                    SetItemDropOnDeath(it, true); // So Builders drop the items when they die
                }
                it = null;
                return false;
            }));
            t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DROP_ITEM);
            TriggerAddCondition(t, Condition(function() -> boolean {
                item it = GetManipulatedItem();
                if (GetUnitAbilityLevel(GetTriggerUnit(), 'A04A') > 0){ // Has Hunter inventory
                    SetItemDropOnDeath(it, true); // So Builders drop the items when they die
                }
                it = null;
                return false;
            }));
            t = null;
        }
    }
}

//! endzinc