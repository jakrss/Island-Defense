//! zinc
library WardDamageAmplification {
	//Constants I guess.
	private constant integer UnitType = 'n01P';
	
	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
		TriggerAddCondition(t, function() {
			unit Target = GetTriggerUnit();
			unit Attacker;
			//Let's check if it is a ward we want to check:
			if((GetUnitTypeId(Target) == UnitType)) {
				Attacker = GetEventDamageSource();
				if(GetUnitAbilityLevel(Attacker, 'BLDR') == 0 && GetUnitAbilityLevel(Attacker, 'TIHU') == 0) {
				BlzSetEventDamage(1);
				}
			}
			Target = null;
			Attacker = null;
		});
		t = null;
	}
}
//! endzinc