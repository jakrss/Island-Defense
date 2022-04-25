//! zinc
library StructureUpgrades {
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_FINISH);
        TriggerAddCondition(t, function() -> boolean {
            //Only for Draenei right now
            if(GetResearched() == 'R02G') {
                SetPlayerTechMaxAllowed(GetOwningPlayer(GetTriggerUnit()), 'R033', -1);
            }
            return false;
        });
    }
}
//! endzinc