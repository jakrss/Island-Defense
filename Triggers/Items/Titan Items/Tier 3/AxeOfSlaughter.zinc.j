//! zinc
library AxeofSlaughter requires ItemExtras, Manhunt {
    //Item ID for Axe of Slaughter
    private constant integer ITEM_ID = 'I03H';
	private constant integer SLAUGHTER_ID = 'A0NI';
    
    private function onInit() {
        trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
		TriggerAddCondition(t, function() {
			unit u = GetEventDamageSource();
			unit t = GetTriggerUnit();
			if(GetUnitAbilityLevel(u, SLAUGHTER_ID) > 0) {
				UnitRemoveAbility(u, SLAUGHTER_ID);
				UnitDamageTarget(u, t, GetUnitState(t, UNIT_STATE_MAX_LIFE) * 0.20, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null);
				//BJDebugMsg("MASSACRE!");
			}
			u = null;
			t = null;
		});
		t = null;
		t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
        TriggerAddCondition(t, function () {
            unit u = GetKillingUnit();
            unit t = GetTriggerUnit();
			if(UnitHasItemById(u, ITEM_ID)) {
				UnitAddAbility(u, SLAUGHTER_ID);
            }
            u = null;
			t = null;
        });
        t=null;
    }
}
//! endzinc