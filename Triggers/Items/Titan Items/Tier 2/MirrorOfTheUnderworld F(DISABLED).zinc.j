//! zinc
library MirrorOfTheUnderworld {
	//Item ID Mirror of the Underworld
	private constant integer ITEM_ID = 'I077';
	//Ethereal ability ID
	private constant integer ABILITY_ID = 'A0NJ';
	//Duration of no collision
	private constant real DURATION = 10.0;
	//Hashtable
	private hashtable mirrorTable = InitHashtable();
	
	function onExpire() {
		timer t = GetExpiredTimer();
		integer tHandle = GetHandleId(t);
		unit target = LoadUnitHandle(mirrorTable, 0, tHandle);
		
		SetUnitPathing(target, true);
		
		FlushChildHashtable(mirrorTable, tHandle);
		DestroyTimer(t);
		target = null;
		t = null;
	}
	
	function onCast() {
		timer cTimer = CreateTimer(); //timer to turn off collision
		integer timerHandle = GetHandleId(cTimer);
		unit target = GetSpellTargetUnit();
		
		SetUnitPathing(target, false);
		
		SaveUnitHandle(mirrorTable, 0, timerHandle, target);
		
		TimerStart(cTimer, DURATION, false, function onExpire);
	}

	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, function() -> boolean {
			unit target = GetSpellTargetUnit();
			if(GetSpellAbilityId() == ABILITY_ID) {
				if(IsUnitType(target, UNIT_TYPE_STRUCTURE)) {
					onCast();
				}
			}
			target = null;
			return false;
		});
		t=null;
	}
	
}
//! endzinc