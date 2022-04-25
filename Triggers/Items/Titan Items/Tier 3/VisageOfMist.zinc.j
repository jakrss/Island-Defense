//! zinc
library VisageOfMist requires ItemExtras, BUM {
    //Item ID of Visage of Fear
    private constant integer ITEM_ID = 'I086';
	private constant integer Evasion = 'A0MM';
	private constant integer ACTIVE_ID = 'A0MJ';
	private hashtable ShunHash = InitHashtable();
    
	private function Shunning() {
		timer t = GetExpiredTimer();
		unit u = LoadUnitHandle(ShunHash, GetHandleId(t), 0);
		integer i = GetUnitAbilityLevel(u, Evasion);
		if(i == 0 && UnitHasItemById(u, ITEM_ID) == true) {
			UnitAddAbility(u, Evasion);
		}
		u = null;
	}
	
	private function ShunningRemove() {
		timer t = GetExpiredTimer();
		unit u = LoadUnitHandle(ShunHash, GetHandleId(t), 0);
		UnitRemoveAbility(u, Evasion);
		FlushChildHashtable(ShunHash, GetHandleId(t));
		DestroyTimer(t);
		u = null;
	}
	
    private function onInit() {
        trigger t = CreateTrigger();
        onAcquireItem(t);
        TriggerAddCondition(t, function() {
            unit u = GetTriggerUnit();
            item i = GetManipulatedItem();
			integer n = GetItemCountFromUnitById(u, ITEM_ID);
			timer t;
            if(GetItemTypeId(i) == ITEM_ID && n <= 1) {
                t = CreateTimer();
				TimerStart(t, 3.00, true, function Shunning);
				SaveTimerHandle(ShunHash, GetHandleId(u), 0, t);
				SaveUnitHandle(ShunHash, GetHandleId(t), 0, u);
            }
            u = null;
            i = null;
			t = null;
        });
        t = null;
        t = CreateTrigger();
        onLoseItem(t);
        TriggerAddCondition(t, function() {
            unit u = GetTriggerUnit();
            item i = GetManipulatedItem();
			integer n = GetItemCountFromUnitById(u, ITEM_ID);
			timer t;
	    if(GetItemTypeId(i) == ITEM_ID && n <= 1) {
			t = LoadTimerHandle(ShunHash, GetHandleId(u), 0);
			UnitRemoveAbility(u, Evasion);
            if(t != null) {
                FlushChildHashtable(ShunHash, GetHandleId(t));
                FlushChildHashtable(ShunHash, GetHandleId(u));
                DestroyTimer(t);
            }
		}
            u = null;
            i = null;
            t = null;
        });
        t = null;
		t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ATTACKED);
		TriggerAddCondition(t, function() {
			unit u = GetTriggerUnit();
			timer t;
			if(GetUnitAbilityLevel(u, Evasion) > 0) {
				t = CreateTimer();
				TimerStart(t, 0.25, false, function ShunningRemove);
				SaveUnitHandle(ShunHash, GetHandleId(t), 0, u);
			}
		});
		
	}
}
//! endzinc