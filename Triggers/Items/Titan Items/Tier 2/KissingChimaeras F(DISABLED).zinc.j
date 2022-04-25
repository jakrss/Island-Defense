//! zinc
library KissingChimaeras requires BonusMod, ItemExtras, Scouting {
	//Item ID for KissingChimaeras
	private constant integer ITEM_ID = 'I06Z';
	//Ability ID of the active
	private constant integer ABILITY_ID = 'A0FH';
	//Greater Chimaera Scout ID
	private constant integer DUMMY_ID = 'u010';
	//Duration of Chimaera Scout
	private constant real DURATION = 70.0;

	//Whenever a unit casts a spell and has the item
	function onSpell() {
	    unit caster = GetTriggerUnit();
	    unit chimaera = null;
	    real tX = GetUnitX(caster);
	    real tY = GetUnitY(caster);
            
	    chimaera = CreateUnit(GetOwningPlayer(caster), DUMMY_ID, tX, tY, bj_UNIT_FACING);
	    UnitApplyTimedLife(chimaera, 'BTLF', DURATION);
	    chimaera = null;
	    caster = null;
	}
	

	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, function() -> boolean {
			if(GetSpellAbilityId() == ABILITY_ID) {
				onSpell();
			}
			return false;
		});
		t = null;
	}
	
}
//! endzinc