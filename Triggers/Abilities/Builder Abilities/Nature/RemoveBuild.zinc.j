//! zinc

library NatureRemoveBuild {
    private constant integer ABILITY_ID = 'AEbu';
    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_FINISH);
        TriggerAddCondition(t , Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            integer id = GetUnitTypeId(u);
            if (id == 'e003' || // Mystics
                id == 'h00T' || // Protectors
                id == 'h00R'){  // Spear Throwers
                UnitRemoveAbility(u, ABILITY_ID);
            }
            
            u = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc