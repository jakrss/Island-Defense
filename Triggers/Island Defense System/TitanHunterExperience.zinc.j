//! zinc
library TitanHunterExperience {
	//Generic:
	private constant integer CritterXP = 5;
	private constant integer UnitXP = 25;
	private constant integer HeroXP = 350;
	private constant real XPSpillRange = 1000;
	private constant real dmgXexpFactor = 0.0015;
	private hashtable XPHash = InitHashtable();

	private function addExp(unit u, integer xp) {
		SuspendHeroXP(u, false);
		AddHeroXP(u, xp, true);
		SuspendHeroXP(u, true);
		u = null;
	}
	
	private function isTitanHunter() -> boolean {
		return GetUnitAbilityLevel(GetFilterUnit(), 'TIHU') > 0;
	}
	
	private function expTimerexp() {
		timer tim = GetExpiredTimer();
		unit titan = LoadUnitHandle(XPHash, GetHandleId(tim), 1);
		unit hunter;
		real xp;
		real xpOriginal;
		real X = GetUnitX(titan);
		real Y = GetUnitY(titan);
		group xpGroup = CreateGroup();
		boolean bTitanHunterInvolved = LoadBoolean(XPHash, GetHandleId(tim), 2);
		real rRangeExtent = LoadReal(XPHash, GetHandleId(tim), 3);
		xpOriginal = LoadReal(XPHash, GetHandleId(tim), 0) * dmgXexpFactor;
		//Let's give 0.003% of damage as experience - but only if a Titan Hunter has dealt damage during the timer's lifetime:
		if(bTitanHunterInvolved) {
			GroupEnumUnitsInRange(xpGroup, X, Y, rRangeExtent, function isTitanHunter);
			hunter = FirstOfGroup(xpGroup);
			while(hunter != null) {
				if(GetHeroLevel(hunter) < 2) xp = xpOriginal * 2 + 2;
				else if(GetHeroLevel(hunter) < 3) xp = xpOriginal * 1.5 + 1;
				else if(GetHeroLevel(hunter) < 4) xp = xpOriginal;
				else xp = xpOriginal;
				addExp(hunter, R2I(xp));
				GroupRemoveUnit(xpGroup, hunter);
				hunter = null;
				hunter = FirstOfGroup(xpGroup);
			}
		}
		DestroyTimer(tim);
		FlushChildHashtable(XPHash, GetHandleId(titan));
		FlushChildHashtable(XPHash, GetHandleId(tim));
		DestroyGroup(xpGroup);
		xpGroup = null;
		tim = null;
		hunter = null;
		titan = null;
	}

    private function onInit(){
        trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
		TriggerAddCondition(t, Condition(function() -> boolean {
			real tX;
			real tY;
			group heroGroup;
			unit killer = GetKillingUnit();
			unit target = GetDyingUnit();
			integer iUnitCount = 0;
			//Killing Critters:
			if(GetUnitAbilityLevel(killer, 'TIHU') > 0 && GetUnitAbilityLevel(target, 'CRIT') > 0 && GetHeroLevel(killer) < 4) {
				addExp(killer, CritterXP);
			//Killing non-hero enemy unit:
			} else if(GetUnitAbilityLevel(killer, 'TIHU') > 0 && IsUnitEnemy(target, GetOwningPlayer(killer)) && !IsUnitIllusion(target) && !IsUnitType(target, UNIT_TYPE_HERO)) {
				addExp(killer, UnitXP);
			//Killing a Titanous Hero unit:
			} else if(GetUnitAbilityLevel(target, 'CTIT') > 0) {
				heroGroup = CreateGroup();
				tX = GetUnitX(target);
				tY = GetUnitY(target);
				GroupEnumUnitsInRange(heroGroup, tX, tY, XPSpillRange, function isTitanHunter);
				killer = FirstOfGroup(heroGroup);
				addExp(killer, HeroXP);
				GroupRemoveUnit(heroGroup, killer);
				killer = null;
				iUnitCount = CountUnitsInGroup(heroGroup);
				killer = FirstOfGroup(heroGroup);
				while(killer != null) {
					addExp(killer, ((HeroXP/2)/iUnitCount));
					GroupRemoveUnit(heroGroup, killer);
					killer = FirstOfGroup(heroGroup);
				}
			}
			DestroyGroup(heroGroup);
			heroGroup = null;
			killer = null;
			target = null;
		return false;
		}));
		t = null;
		t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
		TriggerAddCondition(t, Condition(function() -> boolean {
			unit titanousUnit = GetTriggerUnit();
			real storedDMG = GetEventDamage();
			timer ExperienceTimer;
			boolean bTitanHunterInvolved;
			real rRangeExtent;
			if(storedDMG > 0 && GetUnitAbilityLevel(titanousUnit, 'CTIT') > 0) {
				ExperienceTimer = LoadTimerHandle(XPHash, GetHandleId(titanousUnit), 0);
				rRangeExtent = LoadReal(XPHash, GetHandleId(ExperienceTimer), 3);
				bTitanHunterInvolved = LoadBoolean(XPHash, GetHandleId(ExperienceTimer), 2);	//Specifies if a Titan Hunter has been involved at any step of the way.
				if(ExperienceTimer == null) {
					ExperienceTimer = CreateTimer();
					TimerStart(ExperienceTimer, 2.00, false, function expTimerexp);
					SaveTimerHandle(XPHash, GetHandleId(titanousUnit), 0, ExperienceTimer);
				}
				if(!bTitanHunterInvolved && GetUnitAbilityLevel(GetEventDamageSource(), 'TIHU') > 0) {
					rRangeExtent = XPSpillRange;
					bTitanHunterInvolved = true;
					SaveBoolean(XPHash, GetHandleId(ExperienceTimer), 2, bTitanHunterInvolved);
				}
				//If attacking Titan Hunter has higher attack range than the default distribution range:
				if(bTitanHunterInvolved && GetUnitAbilityLevel(GetEventDamageSource(), 'TIHU') > 0 && BlzGetUnitWeaponRealField(GetEventDamageSource(), UNIT_WEAPON_RF_ATTACK_RANGE, 0) >= rRangeExtent) {
					rRangeExtent = BlzGetUnitWeaponRealField(GetEventDamageSource(), UNIT_WEAPON_RF_ATTACK_RANGE, 0) + 128;
				}
				storedDMG = LoadReal(XPHash, GetHandleId(ExperienceTimer), 0) + GetEventDamage();
				SaveReal(XPHash, GetHandleId(ExperienceTimer), 0, storedDMG);
				SaveReal(XPHash, GetHandleId(ExperienceTimer), 3, rRangeExtent);
				SaveUnitHandle(XPHash, GetHandleId(ExperienceTimer), 1, titanousUnit);
			}
		return false;
		}));
		t = null;
    }
}

//! endzinc