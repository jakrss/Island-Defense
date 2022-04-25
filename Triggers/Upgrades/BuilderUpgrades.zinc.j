//! zinc
library BuilderUpgrades {
    private constant integer BACKPACK_ID = 'A013';
    
    private function CheckBackpack() -> boolean {
        unit u = GetFilterUnit();
        if(GetUnitAbilityLevel(u, BACKPACK_ID) > 0) {
            return true;
        }
        u=null;
        return false;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_FINISH);
        TriggerAddCondition(t, function() -> boolean {
            group g;
            unit u;
            //Backpack research for builders
            if(GetResearched() == 'R03J') {
                g = CreateGroup();
                GroupEnumUnitsOfPlayer(g, GetOwningPlayer(GetTriggerUnit()), function CheckBackpack);
                u=FirstOfGroup(g);
                while(u!=null) {
                    IncUnitAbilityLevel(u, BACKPACK_ID);
                    GroupRemoveUnit(g, u);
                    u=null;
                    u=FirstOfGroup(g);
                }
                DestroyGroup(g);
            }
            return false;
        });
        t=null;
    }
}
//! endzinc