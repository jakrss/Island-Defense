//! zinc
library InvulnerableItems {
    public struct InvulnerableItems {
        public static method checkItem(item it) {
            itemtype t = GetItemType(it);
            if ((t == ITEM_TYPE_PERMANENT ||
                 t == ITEM_TYPE_ARTIFACT) &&
                !IsItemInvulnerable(it)){
                SetItemInvulnerable(it, true);
            }
            it = null;
        }
        
        private static method onInit(){
            trigger t = CreateTrigger();
            
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_PICKUP_ITEM);
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DROP_ITEM);
            TriggerAddCondition(t, Condition(function() -> boolean {
                item it = GetManipulatedItem();
                thistype.checkItem(it);
                it = null;
                return false;
            }));
            t = null;
        }
    }
}

//! endzinc