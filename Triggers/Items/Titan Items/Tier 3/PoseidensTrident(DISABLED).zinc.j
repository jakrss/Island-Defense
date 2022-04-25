//! zinc
library PoseidonsTrident requires BonusMod {
	//Item ID for Poseidon's Trident
	private constant integer ITEM_ID = 'I06A';
	//Bonus damage added
	private constant real DAMAGE = 50;
	//Damage effect
	private constant string EFFECT = "Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveDamage.mdl";
	private constant attacktype AT = ATTACK_TYPE_CHAOS;
	private constant damagetype DT = DAMAGE_TYPE_UNIVERSAL;
	private constant weapontype WT = WEAPON_TYPE_WHOKNOWS;

	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
		TriggerAddCondition(t, function() -> boolean {
		    unit attacker = GetEventDamageSource();
		    unit target = GetTriggerUnit();
		    integer numTridents;
                    trigger tr = GetTriggeringTrigger();
		    if(UnitHasItemById(attacker, ITEM_ID) && IsUnitType(target, UNIT_TYPE_STRUCTURE) && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {
                        DisableTrigger(tr);
		        numTridents = GetItemCountFromUnitById(attacker, ITEM_ID);
		        UnitDamageTarget(attacker, target, DAMAGE * numTridents, false, false, AT, DT, WT);
		        DestroyEffect(AddSpecialEffectTarget(EFFECT, target, "origin"));
                        EnableTrigger(tr);
		    }
		    attacker = null;
		    target = null;
                    tr = null;
		    return false;
		});
		t=null;
	}
	
}
//! endzinc