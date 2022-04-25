//! zinc

library MolteniousUnique {
	private constant real Interval = 0.500; //How often the unique damages stuff.
	private constant integer Unique = 'TMAR'; //Unique ID.
	private constant real Range = 250;	//Range of the unique effect.
	private constant real Amplifier = 2.00; //What amplification should Incinerate do?
	private constant real DamagePerLevel = 10; //5 + DamagePerLevel
	private constant string TargetEf = "Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeDamageTarget.mdl";
	private constant integer AmpBuff = 'B03Q';
	private constant integer HiddenAbil = 'A0NE';
	private hashtable MoHa = InitHashtable();
	
	private function Periodic(){
		group TargetGroup = CreateGroup();
		unit Moltenious = LoadUnitHandle(MoHa, GetHandleId(GetExpiredTimer()), 0);
		unit Target;
		real XLoc = GetUnitX(Moltenious);
		real YLoc = GetUnitY(Moltenious);
		real damage;
		//Check for Smoke Screen, Fog Generator and general Wind Walk buff.
		if(GetUnitAbilityLevel(Moltenious, 'B00P') < 1 && GetUnitAbilityLevel(Moltenious, 'A0MO') < 1 && GetUnitAbilityLevel(Moltenious, 'BOwk') < 1) {
		GroupEnumUnitsInRange(TargetGroup, XLoc, YLoc, Range, null);
		Target = FirstOfGroup(TargetGroup);
		while (Target != null) {
			if(!IsUnitAlly(Target, GetOwningPlayer(Moltenious)) && IsUnitType(Target, UNIT_TYPE_STRUCTURE) == true && !IsUnitType(Target, UNIT_TYPE_MAGIC_IMMUNE)) {
				damage = 5 + DamagePerLevel * GetUnitAbilityLevel(Moltenious, Unique);
				//Check if the damage is amplified by Incinerate:
				if(UnitHasBuffBJ(Target, AmpBuff)) damage = damage * Amplifier;
				//Damage those bastards:
				UnitDamageTarget(Moltenious, Target, damage, false, false, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_MAGIC, null);
				DestroyEffect(AddSpecialEffectTarget(TargetEf, Target, "origin"));
			}
			GroupRemoveUnit(TargetGroup, Target);
			Target = FirstOfGroup(TargetGroup);
		}
		GroupClear(TargetGroup);
		DestroyGroup(TargetGroup);
		Target = null;
		TargetGroup = null;
		Moltenious = null;
	}}
	
	private function onInit(){
        trigger t = CreateTrigger();
		GT_RegisterLearnsAbilityEvent(t, Unique);
		TriggerAddCondition(t, function() -> boolean {
			timer TimInt;
			unit Moltenious = GetLearningUnit();
			integer level = GetLearnedSkillLevel();
			real XLoc = GetUnitX(Moltenious);
			real YLoc = GetUnitY(Moltenious);
			//Check that it is first-time learning:
			if(level == 1) {
				TimInt = CreateTimer();
				TimerStart(TimInt, Interval, true, function Periodic);
				UnitAddAbility(Moltenious, HiddenAbil);
			}
			SaveUnitHandle(MoHa, GetHandleId(TimInt), 0, Moltenious);
			
		Moltenious = null;
		return false;
		});
    }
}

//! endzinc