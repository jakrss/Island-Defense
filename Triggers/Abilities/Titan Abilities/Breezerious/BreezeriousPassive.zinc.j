//! zinc
library BreezeriousPassive {
    private constant integer abilityId = 'A0B9';
    //Attack speed ability bonus
    private constant integer asAbilityId = 'A09L';
    //Move speed ability bonus
    private constant integer msAbilityId = 'A0B8';
	//Else:
	private constant real duration = 2.0;
	private constant boolean SendDebug = false;
    hashtable fastTable = InitHashtable();


	function removeStacks() {
	    timer tim = GetExpiredTimer();
	    unit attacker = LoadUnitHandle(fastTable, 0, GetHandleId(tim));
	    integer asLevel = GetUnitAbilityLevel(attacker, asAbilityId);
        integer msLevel = GetUnitAbilityLevel(attacker, msAbilityId);		
		boolean loopingNow = LoadBoolean(fastTable, 1, GetHandleId(tim));
		//Check if the timer expired is the looping one, if not, blast it with fire and make a looping one:
		if(!loopingNow) {
			TimerStart(tim, 0.25, true, function removeStacks);
			loopingNow = true;
			SaveBoolean(fastTable, 1, GetHandleId(tim), loopingNow);
			if(SendDebug) BJDebugMsg("Creating looping timer!");
			}
	    if(asLevel > 1 && msLevel > 1) {
				if(SendDebug) BJDebugMsg("Decreasing level.");
                DecUnitAbilityLevel(attacker, asAbilityId);
                DecUnitAbilityLevel(attacker, msAbilityId);
			//If the levels are 1 and the timer is still looping, just kill it.
            } else if(loopingNow) {
				if(SendDebug) BJDebugMsg("Flushing all.");
				DestroyTimer(tim);
				FlushChildHashtable(fastTable, GetHandleId(tim));
				FlushChildHashtable(fastTable, GetHandleId(attacker));
				loopingNow = false;
				}
		tim = null;
		attacker = null;
	}

	function onAttack(unit t, unit attacker) {
	    integer asLevel = GetUnitAbilityLevel(attacker, asAbilityId);
        integer msLevel = GetUnitAbilityLevel(attacker, msAbilityId);
	    timer tim = LoadTimerHandle(fastTable, 1, GetHandleId(attacker));
	    if(asLevel < 10 && msLevel < 10) {
                IncUnitAbilityLevel(attacker, asAbilityId);
                IncUnitAbilityLevel(attacker, msAbilityId);
				if(SendDebug) BJDebugMsg("Increasing level.");
            }
	    if (tim != null) DestroyTimer(tim);
	    tim = CreateTimer();
	    TimerStart(tim, duration, false, function removeStacks);
	    SaveTimerHandle(fastTable, 1, GetHandleId(attacker), tim);
	    // Save the unit to the timer so we know who we talkin bout willis
	    SaveUnitHandle(fastTable, 0, GetHandleId(tim), attacker);
	    tim = null;
		attacker = null;
		t = null;
	    }
		
		private function onInit() {
		    trigger t = CreateTrigger();
		    TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        	    TriggerAddCondition(t, Condition(function()-> boolean {
            		unit a = GetEventDamageSource();
					unit t = GetTriggerUnit();
			if ( GetUnitAbilityLevel(a, 'A0B9') > 0 && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL && IsUnitEnemy(t, GetOwningPlayer(a))) {
			    onAttack(t, a);
			}
			a = null;
			t = null;
			return false;
		    }));
		    t = null;
		}
}
//! endzinc