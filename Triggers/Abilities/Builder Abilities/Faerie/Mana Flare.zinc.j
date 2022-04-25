//! zinc
library FaerieManaFlare {
    private constant integer DURATION = 8;
    private constant integer DUMMY_ID = 'o03J';
    private constant integer ORDER_ID = 852512;
    private constant integer SPELL_ID = 'A05X';
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
            unit tempUnit;
            if(GetSpellAbilityId() == SPELL_ID) {
                tempUnit = CreateUnit(GetOwningPlayer(GetTriggerUnit()), DUMMY_ID, GetSpellTargetX(), GetSpellTargetY(), bj_UNIT_FACING);
                UnitApplyTimedLife(tempUnit, 'BTLF', DURATION);
            }
            return false;
        });
        t=null;
    }
}
//! endzinc