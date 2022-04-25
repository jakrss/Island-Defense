//! zinc
library EntanglingGrowth {
	//Entanglement (Arborius) code:
	private constant integer Unique = 'TAAR';
	private constant integer ArboriusCode = 'TITA';
	//Static stats:
	private constant integer Enemy_Info = 'A0KQ';
	private constant integer DamageReduction = 'TAAV';
	private constant integer AttackSpeedBurst = 'TAAA';
	private constant integer BurstAttacks = 2;
	private constant real BurstDuration = 3;
	private constant real BurstRange = 200;
	private constant real EntanglementChance = 0.15;
	private constant real EntanglementDuration = 6;
	private constant string EffectCode = "Abilities\\Spells\\NightElf\\EntanglingRoots\\EntanglingRootsTarget.mdl";
	//Hashtable
	hashtable Hash = InitHashtable();
	//---------------------------------------------

	private function EntangleExpiration() {
		timer Timer = GetExpiredTimer();
		unit Attacker = LoadUnitHandle(Hash, GetHandleId(Timer), 0);
		effect Effect = LoadEffectHandle(Hash, GetHandleId(Attacker), 0);
		UnitRemoveAbility(Attacker, DamageReduction);
		UnitRemoveAbility(Attacker, Enemy_Info);
		UnitRemoveBuffBJ('BTAR', Attacker);
		DestroyEffect(Effect);
		FlushChildHashtable(Hash, GetHandleId(Timer));
		FlushChildHashtable(Hash, GetHandleId(Attacker));
		Effect = null;
		Attacker = null;
		Timer = null;
	}
	
	private function BurstExpiration() {
		timer BurstTimer = GetExpiredTimer();
		unit Arborius = LoadUnitHandle(Hash, 0, GetHandleId(BurstTimer));
		SetUnitAbilityLevel(Arborius, AttackSpeedBurst, 1);
		UnitRemoveAbility(Arborius, AttackSpeedBurst);
		FlushChildHashtable(Hash, GetHandleId(BurstTimer));
		FlushChildHashtable(Hash, GetHandleId(Arborius));
		//BJDebugMsg("Removing burst, timer out");
		Arborius = null;
		BurstTimer = null;
	}
	
	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
		TriggerAddCondition(t, function() -> boolean {
			unit Attacker = GetEventDamageSource();
			unit Arborius = GetTriggerUnit();
			real Roll;
			timer Timer;
			timer BurstTimer = CreateTimer();
			effect Effect;
			if(GetUnitTypeId(Arborius) == ArboriusCode && GetUnitAbilityLevel(Arborius, Unique) > 0 && IsUnitEnemy(Attacker, GetOwningPlayer(Arborius)) && IsUnitType(Attacker, UNIT_TYPE_STRUCTURE) == true) {
				Roll = GetRandomReal(0, 1);
				if(Roll <= EntanglementChance) {
					//BJDebugMsg("Entanglement Activated");
					//Let's check that the unit is not already Entangled:
					if(GetUnitAbilityLevel(Attacker, DamageReduction) == 0) {
						//BJDebugMsg("New entangle!");
						Timer = CreateTimer();
						UnitAddAbility(Attacker, DamageReduction);
						SetUnitAbilityLevel(Attacker, DamageReduction, GetUnitAbilityLevel(Arborius, Unique));
						Effect = AddSpecialEffectTarget(EffectCode, Attacker, "origin");
						SaveEffectHandle(Hash, GetHandleId(Attacker), 0, Effect);
						BlzSetSpecialEffectScale(Effect, 4.5);
						UnitAddAbility(Attacker, Enemy_Info);
						if(UnitHasBuffBJ(Attacker, 'BTAS') == true) {
							UnitAddAbility(Arborius, AttackSpeedBurst);
							if(GetUnitAbilityLevel(Arborius, AttackSpeedBurst) < 7) {
							SetUnitAbilityLevel(Arborius, AttackSpeedBurst, GetUnitAbilityLevel(Arborius, AttackSpeedBurst) + BurstAttacks);
							}
							SaveUnitHandle(Hash, GetHandleId(BurstTimer), 0 , Arborius);
							SaveTimerHandle(Hash, GetHandleId(Arborius), 0, BurstTimer);
							TimerStart(BurstTimer, BurstDuration, false, function BurstExpiration);
						}
						SaveUnitHandle(Hash, GetHandleId(Timer), 0, Attacker);
					} else {
						//BJDebugMsg("Already entangled, renew!");
						Timer = LoadTimerHandle(Hash, GetHandleId(Attacker), 0);
						SetUnitAbilityLevel(Attacker, DamageReduction, GetUnitAbilityLevel(Arborius, Unique));
						
					}
				TimerStart(Timer, EntanglementDuration, false, function EntangleExpiration);
				}
			}
			if(GetUnitAbilityLevel(Attacker, AttackSpeedBurst) > 0 && GetUnitTypeId(Attacker) == ArboriusCode && IsUnitEnemy(Attacker, GetOwningPlayer(Arborius)) && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL){
				//BJDebugMsg("Burst attack!");
				DecUnitAbilityLevel(Attacker, AttackSpeedBurst);
				if(GetUnitAbilityLevel(Attacker, AttackSpeedBurst) == 1) {
					UnitRemoveAbility(Attacker, AttackSpeedBurst);
					BurstTimer = LoadTimerHandle(Hash, GetHandleId(Attacker), 0);
					FlushChildHashtable(Hash, GetHandleId(BurstTimer));
					FlushChildHashtable(Hash, GetHandleId(Attacker));
					DestroyTimer(BurstTimer);
					//BJDebugMsg("Removing burst, all spent");
				}
			}
			Attacker = null;
			Arborius = null;
			Effect = null;
			Timer = null;
			BurstTimer = null;
		return false;
		});
		t = null;
	}
	
}
//! endzinc