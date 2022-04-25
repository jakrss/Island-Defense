//! zinc
library MolteniousPhoenix {
    private integer abilityId = 'TMAD';
    
    private function CheckTargets() -> boolean {
        unit u = GetFilterUnit();
        integer id = GetUnitTypeId(u);
        if(id == 'tMT1' || id == 'h03F') {
            return true;
        }
        return false;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
            unit u = null;
            group g;
            if(GetSpellAbilityId() == abilityId) {
                g = CreateGroup();
                GroupEnumUnitsOfPlayer(g, GetOwningPlayer(GetTriggerUnit()), function CheckTargets);
                u=FirstOfGroup(g);
                while(u != null) {
                    RemoveUnit(u);
                    GroupRemoveUnit(g, u);
                    u=null;
                    u=FirstOfGroup(g);
                }
            }
            return false;
        });
        t=null;
    }
}
//! endzinc