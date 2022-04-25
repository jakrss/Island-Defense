//! zinc
library RockSolidStrategy {
	private constant integer aRockSolidStrategy = 'A0FV';
	private constant real interval = 3.00;
	private hashtable rockHash = InitHashtable();

	function expirationTimer() {
		timer cooldownTimer = GetExpiredTimer();
		unit Panda = LoadUnitHandle(rockHash, 0, GetHandleId(cooldownTimer));
		if(GetPlayerTechCount(GetOwningPlayer(Panda), 'R041', false) == 1) {
			SetUnitAbilityLevel(Panda, aRockSolidStrategy, 3);
		} else if(GetPlayerTechCount(GetOwningPlayer(Panda), 'R025', false) == 2) {
			SetUnitAbilityLevel(Panda, aRockSolidStrategy, 2);
		}
		FlushChildHashtable(rockHash, GetHandleId(cooldownTimer));
		DestroyTimer(cooldownTimer);
		Panda = null;
		
	}

    private function onInit() {
        trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
		TriggerAddCondition(t, function() {
			unit target = GetTriggerUnit();
			unit attacker = GetEventDamageSource();
			timer cooldownTimer;
			if(GetUnitAbilityLevel(attacker, aRockSolidStrategy) >= 0 && GetPlayerTechCount(GetOwningPlayer(attacker), 'R025', false) == 2) {
				SetUnitAbilityLevel(attacker, aRockSolidStrategy, 0);
				cooldownTimer = CreateTimer();
				TimerStart(cooldownTimer, interval, false, function expirationTimer);
				SaveUnitHandle(rockHash, 0, GetHandleId(cooldownTimer), attacker);
				if(GetPlayerTechCount(GetOwningPlayer(attacker), 'R041', false) == 1) UnitRemoveBuffsBJ( bj_REMOVEBUFFS_NEGATIVE, attacker);
			}
			target = null;
			attacker = null;
			cooldownTimer = null;
		});
		t = null;
    }
}
//! endzinc