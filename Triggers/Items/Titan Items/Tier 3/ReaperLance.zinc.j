//! zinc
library ReaperLance requires ItemExtras {
    //Item ID
    private constant integer ITEM_ID = 'I07F';
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
        TriggerAddCondition(t, function() {
            unit a = GetKillingUnit();
            unit d = GetTriggerUnit();
			unit x;
			real XLoc = GetUnitX(d);
			real YLoc = GetUnitY(d);
            if(UnitHasItemById(a, ITEM_ID) && IsUnitType(d, UNIT_TYPE_STRUCTURE)) {
				x = CreateUnit(GetOwningPlayer(a), 'e01B', XLoc, YLoc, 0);
				UnitAddAbility(x, 'A0NY');
				IssueImmediateOrderById(x, 852588);
				RemoveUnit(x);
            }
            a = null;
            d = null;
			x = null;
	    });
	t=null;	
    }    
}
//! endzinc
