//! zinc
library TitanTrident requires BonusMod {
	//Item ID for Titanic Trident
	private constant integer TITANIC = 'I01P';		//Pure damage = 10+10
	private constant integer REAPER = 'I07F';		//Pure damage = 15+10
	private constant integer POSEIDON = 'I06A';		//Pure damage = 20+15
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
			integer level = GetHeroLevel(attacker);
			integer DAMAGE;
                   trigger tr = GetTriggeringTrigger();
			//Check which item offers the best Titan-ability.
			//Poseidon's Trident
			if(UnitHasItemById(attacker, POSEIDON)) { 
				DAMAGE = 20 + (level);
				if(level > 15) DAMAGE = 35;
			}
				else if(UnitHasItemById(attacker, REAPER)) { 
					DAMAGE = 15 + (level);
				if(level > 10) DAMAGE = 25;
				}
					else if(UnitHasItemById(attacker, TITANIC)) { 
						DAMAGE = 10 + (level);
				if(level > 10) DAMAGE = 20;
					}
						else DAMAGE = 0;
			if(DAMAGE > 0 && IsUnitType(target, UNIT_TYPE_STRUCTURE) && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {
                        DisableTrigger(tr);
		        UnitDamageTarget(attacker, target, DAMAGE, false, false, AT, DT, WT);
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