//! zinc
library VoltronDischarge {
    private constant integer DUMMY = 'e01B';
    private constant integer ORDER_ID = 852066;
    private constant integer STEALTH_ID = 'TVA0';
	private constant integer MINI_STEALTH_ID = 'TVNW';
	private constant integer DISCHARGE_ID = 'A0NH';
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
			unit voltron = GetTriggerUnit();
            unit xeUnit;
			integer SpellID = GetSpellAbilityId();
			real XLoc = GetUnitX(voltron);
			real YLoc = GetUnitY(voltron);
            if(GetSpellAbilityId() == STEALTH_ID || GetSpellAbilityId() == MINI_STEALTH_ID) {
                xeUnit = CreateUnit(GetOwningPlayer(voltron), DUMMY, XLoc, YLoc, 0);
				UnitAddAbility(xeUnit, DISCHARGE_ID);
				SetUnitAbilityLevel(xeUnit, DISCHARGE_ID, GetUnitAbilityLevel(voltron, SpellID));
                IssueTargetOrderById(xeUnit, ORDER_ID, voltron);
            }
			voltron = null;
			xeUnit = null;
            return false;
        });
        t=null;
    }
}
//! endzinc