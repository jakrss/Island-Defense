//! zinc
library HelmetOfDominator requires MathLibs, ItemExtras {
    //Item ID for Helm of the Dominator
    private constant integer HELMET_ID = 'I030';
	private constant integer AXE_ID = 'I03H';
    //Ability ID of the dummy ability:
    private constant integer DUMABIL = 'A0MS';
    //Duration of effect is defined by the object editor values. 	A0MS
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
        TriggerAddCondition(t, function () -> boolean {
            unit killer = GetKillingUnit();
			unit d;
			real tX;
			real tY;
			real kX;
			real kY;
			real angle;
            if(UnitHasItemById(killer, HELMET_ID) || UnitHasItemById(killer, AXE_ID)) {
				tX = GetUnitX(GetTriggerUnit());
				tY = GetUnitY(GetTriggerUnit());
				kX = GetUnitX(killer);
				kY = GetUnitY(killer);
				angle = getAngle(tX, tY, kX, kY);
                d = CreateUnit(GetOwningPlayer(killer), 'e01B', tX, tY, angle);
				UnitAddAbility(d, DUMABIL);
				IssueTargetOrderById(d, 852066, killer);
				RemoveUnit(d);
            }
			d = null;
            killer = null;
            return false;
        });
        t=null;
    }
    
}
//! endzinc