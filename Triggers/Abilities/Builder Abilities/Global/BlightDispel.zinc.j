//! zinc

library BlightDispel {
    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_FINISH);
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            if (IsUnitType(u, UNIT_TYPE_STRUCTURE) == true) {
                UnitAddAbility(u, 'Abds');
            }
            u = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc