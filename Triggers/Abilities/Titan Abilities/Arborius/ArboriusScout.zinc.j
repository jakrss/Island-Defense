//! zinc
library ArboriusScout {
	private constant integer VisionTrailDummy = 'o03W';
	
	private function SpellQualifies(integer SpellId) -> boolean {
		//The ability must be one of Arborius' abilities:
		if(SpellId == 'TAAQ' || SpellId == 'TAAE'|| SpellId == 'TAAW' || SpellId == 'TAAF') return true;
		return false;
	}
	

	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, function() {
			unit Caster = GetTriggerUnit();
			integer SpellId = GetSpellAbilityId();
			real XLoc;
			real YLoc;
			if(SpellQualifies(SpellId)) {
				//Create Vision:
				XLoc = GetUnitX(Caster);
				YLoc = GetUnitY(Caster);
				UnitApplyTimedLife(CreateUnit(GetOwningPlayer(Caster), VisionTrailDummy, XLoc, YLoc, 0), 'B061', 15);
			}
		Caster = null;
		});
		t = null;

	}
}
//! endzinc