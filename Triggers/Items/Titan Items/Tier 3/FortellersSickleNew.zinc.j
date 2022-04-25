//! zinc
library ForetellerNew requires ItemExtras, Nukes, Healing, BUM {
	private constant integer Overcharge_ID = 'A0NO';
	private constant integer ITEM_ID = 'I07S';
	private constant boolean SendDebug = false;
	private constant string EFFECT = "Abilities\\Spells\\Demon\\DemonBoltImpact\\DemonBoltImpact.mdl";
	
	private function Foreteller(unit c, integer s) -> boolean {
		if(UnitHasItemById(c, ITEM_ID)) {
			if(SendDebug) BJDebugMsg("Unit has Foreteller's Sickle");
			//Now check for the ability cast:
			if(isScout(s) || isStealth(s) || isNuke(s) || isHeal(s) || isUnique(s) || isUltimate(s)) {
				if(SendDebug) BJDebugMsg("Titan ability cast!");
				return true;
			}
		}
		return false;
	}
	
	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, function() {
		    unit c = GetTriggerUnit();
			integer s = GetSpellAbilityId();
			if(Foreteller(c, s)) {
				if(SendDebug) BJDebugMsg("Activating overcharge.");
				UnitAddAbility(c, Overcharge_ID);
				SetUnitAbilityLevel(c, Overcharge_ID, 2);
			}
		c = null;
		});
		t = null;
		t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
		TriggerAddCondition(t, function() {
			unit a = GetEventDamageSource();
			unit t = GetTriggerUnit();
			integer i = GetUnitAbilityLevel(a, Overcharge_ID);
			integer damage;
			if(BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL && i > 0) {
				if(i == 2) {
					SetUnitAbilityLevel(a, Overcharge_ID, 1);
					damage = R2I(GetUnitState(a, UNIT_STATE_MAX_MANA) * 0.03);
					} else if(i == 1) {
					UnitRemoveAbility(a, Overcharge_ID);
					damage = R2I(GetUnitState(a, UNIT_STATE_MAX_MANA) * 0.06);
					}
				UnitDamageTarget(a, t, damage, false, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, null);
				addMana(a, -damage);
				DestroyEffect(AddSpecialEffectTarget(EFFECT, a, "chest"));
			}
			a = null;
			t = null;
		});
		t = null;
	}
	
}
//! endzinc