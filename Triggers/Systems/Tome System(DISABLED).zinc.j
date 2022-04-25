// Written by Neco for Island Defense 3.0.8
// It's purpose is to stop tomes from being consumed by the titan's mound
// Converted to Zinc on 7/6/2011

//! zinc
library TomeSystem {
    private function cond() -> boolean {
        item it = GetManipulatedItem();
        boolean result;
        result = ((GetItemType(it) == ITEM_TYPE_TOME) && (GetItemTypeId(it) != 'I050') && (GetItemTypeId(it) != 'I051'));
        it = null;
        return result;
    }
    
    private function act() {
        integer i = GetItemTypeId(GetManipulatedItem());
        unit u = GetTriggerUnit();
        if (GetUnitTypeId(u) == TITAN_GOLD_MOUND_ID || u == TITAN_GOLD_MOUND) {
            CreateItem(i, GetUnitX(u), GetUnitY(u));
        }
        u = null;
    }
        
    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_PICKUP_ITEM );
        TriggerAddCondition(t, Condition(function cond));
        TriggerAddAction(t, function act);
    }
}
//! endzinc