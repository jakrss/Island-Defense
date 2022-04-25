//! zinc

library RadioHunter requires GT {
    private struct Radiation {
        private static constant integer RADIATION_ID   = 'A0EF';
        private static constant integer RADIOACTIVE_ID = 'u009';
        private static constant integer UNLOAD_ID      = 'A05S';
        private static constant integer RADIOHUNTER_ID = 'H020';
        
        public static method add(unit u){
            UnitAddAbility(u, thistype.RADIATION_ID);
        }
        
        public static method remove(unit u){
            UnitRemoveAbility(u, thistype.RADIATION_ID);
        }
        
        private static method onInit(){
            trigger t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_LOADED);
            TriggerAddCondition(t, Condition(function() -> boolean {
                unit u = GetTransportUnit();
                if (GetUnitTypeId(GetLoadedUnit()) == thistype.RADIOACTIVE_ID){
                    thistype.add(u);
                }
                u = null;
                return false;
            }));
            
            t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER);
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_ORDER);
            TriggerAddCondition(t, Condition(function() -> boolean {
                if (GetIssuedOrderId() == OrderId("unload")){
                    thistype.remove(GetTriggerUnit());
                }
                return false;
            }));
            
            t = CreateTrigger();
            GT_RegisterStartsEffectEvent(t, thistype.UNLOAD_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.remove(GetTriggerUnit());
                return false;
            }));
            
            t = CreateTrigger();
            GT_RegisterUnitDiesEvent(t, thistype.RADIOHUNTER_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.remove(GetTriggerUnit());
                return false;
            }));
            t = null;
        }
    }
}

//! endzinc