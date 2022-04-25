//! zinc
library ABMA requires BUM, MathLibs {
	private hashtable ABMAHASH = InitHashtable();
	private hashtable haDamageBonus = InitHashtable();
    //Library for modifying and manipulating ability cooldowns.
    
	//Adds a desired ability to an unit and removes it after a while:
	//Takes unit, ability ID, duration and buff (if buff = null, does not remove the ability's buff).
	private function ABMAUAATTimer() {
		timer tABMADurationTimer = GetExpiredTimer();
		integer iAbility = LoadInteger(ABMAHASH, GetHandleId(tABMADurationTimer), 0);
		unit uUnit = LoadUnitHandle(ABMAHASH, GetHandleId(tABMADurationTimer), 1);
		integer iBuff = LoadInteger(ABMAHASH, GetHandleId(tABMADurationTimer), 2);
		UnitRemoveAbility(uUnit, iAbility);
		if(iBuff != null) UnitRemoveAbility(uUnit, iBuff);
		FlushChildHashtable(ABMAHASH, GetHandleId(tABMADurationTimer));
		DestroyTimer(tABMADurationTimer);
		tABMADurationTimer = null;
		uUnit = null;
	}
	public function ABMAUnitAddAbilityTimed(unit uUnit, integer iAbility, real rTime, integer iBuff) {
		timer tABMADurationTimer = CreateTimer();
		UnitAddAbility(uUnit, iAbility);
		SaveInteger(ABMAHASH, GetHandleId(tABMADurationTimer), 0, iAbility);
		SaveUnitHandle(ABMAHASH, GetHandleId(tABMADurationTimer), 1, uUnit);
		SaveInteger(ABMAHASH, GetHandleId(tABMADurationTimer), 2, iBuff);
		TimerStart(tABMADurationTimer, rTime, false, function ABMAUAATTimer);
		tABMADurationTimer = null;
		uUnit = null;
	}
	
	//This function takes unit, ability code and the percent ratio of the desired cooldown.
	//Takes the cooldown refund as a percentage you wish to reduce the cooldown.
	public function ABMARefundCooldownPercent(unit u, integer i, real r) {
		integer l = GetUnitAbilityLevel(u, i) - 1;
		real c;
		if(r < 1) {
			c = BlzGetAbilityCooldown(i, l) * (1-r);
		} else if (r > 1) {
			c = BlzGetAbilityCooldown(i, l) * ((100-r)/100);
		}
		BlzEndUnitAbilityCooldown(u, i);
		SetUnitAbilityLevel(u, i, l + 1);
		BlzStartUnitAbilityCooldown(u, i, c);
		u = null;
	}
	
	//This function takes unit, ability code and the real as desired cooldown.
	//Starts the ability's cooldown with the desired real.
	public function ABMAStartAbilityCooldown(unit u, integer i, real r) {
		integer lvl = GetUnitAbilityLevel(u, i) - 1;
		BlzEndUnitAbilityCooldown(u, i);
		SetUnitAbilityLevel(u, i, lvl + 1);
		BlzStartUnitAbilityCooldown(u, i, r);
		u = null;
	}
	
	//Refund a percentage of an ability's mana cost.
	public function ABMARefundManacostPercent(unit u, integer i, real r, boolean e) {
		integer l = GetUnitAbilityLevel(u, i) - 1;
		real c = BlzGetUnitAbilityManaCost(u, i, l);
		if(r < 1) {
			c = c * r;
		} else if (r > 1) {
			c = c * (r/100);
		}
		if(e) DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\MoonWell\\MoonWellCasterArt.mdl", u, "origin"));
		if(c > 0) addMana(u, c);
		u = null;
	}
	
	//Rerefund a percentage of an ability's mana cost.
	public function ABMASetUnitAbilityDuration(unit u, integer i, real r) {
		integer l = GetUnitAbilityLevel(u, i) - 1;
		ability a = BlzGetUnitAbility(u, i);
		BlzSetAbilityRealLevelFieldBJ(a, ABILITY_RLF_DURATION_NORMAL, l, r);
		BlzSetAbilityRealLevelFieldBJ(a, ABILITY_RLF_DURATION_HERO, l, r);
		u = null;
		a = null;
	}

    //This function takes unit, ability code and the desired manacost.
    public function ABMASetUnitAbilityManacost(unit u, integer i, integer c) {
        integer l = GetUnitAbilityLevel(u, i) - 1;
        BlzSetAbilityIntegerLevelFieldBJ(BlzGetUnitAbility(u, i), ABILITY_ILF_MANA_COST, l, c);
        u = null;
    }
	
	//Change the Area of Effect of an ability.
	public function ABMASetUnitAbilityAoE(unit u, integer i, real r) {
		integer l = GetUnitAbilityLevel(u, i) - 1;
		ability a = BlzGetUnitAbility(u, i);
		BlzSetAbilityRealLevelFieldBJ(a, ABILITY_RLF_AREA_OF_EFFECT, l, r);
		u = null;
		a = null;
	}
	
	//Retrieve the Area of Effect of an ability.
	public function ABMAGetUnitAbilityAoE(unit u, integer i) -> real {
		integer l = GetUnitAbilityLevel(u, i) - 1;
		ability a = BlzGetUnitAbility(u, i);
		real r = BlzGetAbilityRealLevelField(a, ABILITY_RLF_AREA_OF_EFFECT, l);
		u = null;
		a = null;
		return r;
	}
	
	//Change the cooldown of an ability.
	public function ABMASetUnitAbilityCooldown(unit u, integer i, real r) {
		integer l = GetUnitAbilityLevel(u, i) - 1;
		ability a = BlzGetUnitAbility(u, i);
		BlzSetAbilityRealLevelFieldBJ(a, ABILITY_RLF_COOLDOWN, l, r);
		u = null;
		a = null;
	}
	
	//Change the cast time of an ability.
	public function ABMASetUnitAbilityCastTime(unit u, integer i, real r) {
		integer l = GetUnitAbilityLevel(u, i) -1;
		ability a = BlzGetUnitAbility(u, i);
		BlzSetAbilityRealLevelFieldBJ(a, ABILITY_RLF_CASTING_TIME, l, r);
		BlzSetAbilityRealLevelFieldBJ(a, ABILITY_RLF_CAST_RANGE, l, r);
		u = null;
		a = null;
	}
	
	//Change the Range of an ability.
	public function ABMASetUnitAbilityRange(unit u, integer i, real r) {
		integer l = GetUnitAbilityLevel(u, i) - 1;
		ability a = BlzGetUnitAbility(u, i);
		BlzSetAbilityRealLevelFieldBJ(a, ABILITY_RLF_CAST_RANGE, l, r);
		u = null;
		a = null;
	}
	
	private function ABMARefreshAbilityData(unit u, integer i) {
		IncUnitAbilityLevel(u, i);
		DecUnitAbilityLevel(u, i);
		u = null;
	}
	
	private function fABMADamageExpiration() {
		timer tTimer = GetExpiredTimer();
		integer iDeduction = LoadInteger(haDamageBonus, GetHandleId(tTimer), 0);
		ability aDamageBonus = LoadAbilityHandle(haDamageBonus, GetHandleId(tTimer), 1);
		unit uUnit = LoadUnitHandle(haDamageBonus, GetHandleId(tTimer), 2);
		integer iNewValue = (BlzGetAbilityIntegerLevelField(aDamageBonus, ABILITY_ILF_ATTACK_BONUS, 0) - iDeduction);
		//Debug messages for possibl error if the ability somehow has gotten lost:
		if(aDamageBonus == null) {
			BJDebugMsg("|cffbb2020ABMA Error:|r Damage Expiration calls for null ability! Trying to resolve...");
			aDamageBonus = BlzGetUnitAbility(uUnit, 'ABAD');
			if(aDamageBonus == null) BJDebugMsg("|cffbb2020ABMA Error:|r Resolving failed. Ability cannot be found!");
		}
		//Gets the current damage bonus and deducts the previously granted bonus.
		BlzSetAbilityIntegerLevelFieldBJ(aDamageBonus, ABILITY_ILF_ATTACK_BONUS, 0, iNewValue);
		//If the unit's new bonus is 0, let's remove the ability:
		if(iNewValue == 0) {
			UnitRemoveAbility(uUnit, 'ABAD');	//Technically we might lose it prematurely due to this, if individual bonuses add up to 0 (e.g. +15 - 15 = 0).
			// If it happens, I guess one should just comment out the removal line.
		}
		ABMARefreshAbilityData(uUnit, 'ABAD');
		//Flushing:
		FlushChildHashtable(haDamageBonus, GetHandleId(tTimer));
		//Exit:
		DestroyTimer(tTimer);
		aDamageBonus = null;
		tTimer = null;
		uUnit = null;
	}
	
	//Add desired attack damage bonus to the unit (exclude bonus):
	//This function adds the desired amount for the desired duration.
	//Takes into consideration previously existing effects of this same function - all should hopefully use this.
	public function ABMAAddUnitDamageBonus(unit uUnit, integer iDamageBonus, real rDuration, boolean bPercentBased) {
		integer iAbilityCode = 'ABAD';
		integer iExistingLevel = GetUnitAbilityLevel(uUnit, iAbilityCode);
		ability aDamageBonus = BlzGetUnitAbility(uUnit, iAbilityCode);
		integer iExistingDamage = BlzGetAbilityIntegerLevelField(aDamageBonus, ABILITY_ILF_ATTACK_BONUS, 1);
		timer tDamageBonusTimer;
		if(iDamageBonus == 0) BJDebugMsg("|cffbb2020ABMA Error:|r AddUnitDamageBonus is calling for 0 bonus damage!");
		if(rDuration > 0) tDamageBonusTimer = CreateTimer();	//If rDuration is 0, let's make it infinite. :)
		//Unit already does not have the ability, so let's add it:
		if(iExistingLevel < 1) {
			UnitAddAbility(uUnit, iAbilityCode);
			aDamageBonus = BlzGetUnitAbility(uUnit, iAbilityCode);
		}
		//Set the damage:
		if(bPercentBased) iDamageBonus = (BlzGetUnitWeaponIntegerField(uUnit, UNIT_WEAPON_IF_ATTACK_DAMAGE_BASE, 0) * iDamageBonus / 100);
		iExistingDamage = BlzGetAbilityIntegerLevelField(aDamageBonus, ABILITY_ILF_ATTACK_BONUS, 0);
		BlzSetAbilityIntegerLevelFieldBJ(aDamageBonus, ABILITY_ILF_ATTACK_BONUS, 0, iExistingDamage + iDamageBonus);
		//SetUnitAbilityLevel(uUnit, iAbilityCode, 2);	//This updates the damage amount.
		//SetUnitAbilityLevel(uUnit, iAbilityCode, 1);	//This updates the damage amount.
		ABMARefreshAbilityData(uUnit, iAbilityCode);
		//Save data:
		TimerStart(tDamageBonusTimer, rDuration, false, function fABMADamageExpiration);
		SaveInteger(haDamageBonus, GetHandleId(tDamageBonusTimer), 0, iDamageBonus);
		SaveAbilityHandle(haDamageBonus, GetHandleId(tDamageBonusTimer), 1, aDamageBonus);
		SaveUnitHandle(haDamageBonus, GetHandleId(tDamageBonusTimer), 2, uUnit);
		//Out:
		uUnit = null;
		aDamageBonus = null;
		tDamageBonusTimer = null;
	}
	
	//Temporarily increase movement speed of target by 0-100%.
	public function ABMAMovespeedIncreasePercent(unit u, real duration, real increase) {
		integer i = 'ABMS';
		unit d = CreateUnit(GetOwningPlayer(u), 'e01B', GetUnitX(u), GetUnitY(u), 0);
		//If the value is given in decimals, then we don't need to do a thing.
		//If the value is 0, let's assume infinite speed is wanted.
		if(increase == 0) {
			increase = 10000;	
		//But we can also deal with values over 1 or below -1:
		} else if (increase > 1 || increase < -1) {
			increase = (increase/100);
		}
		SetUnitFacingToFaceUnitTimed(d, u, 0);
		UnitAddAbility(d, i);
		BlzSetAbilityRealLevelFieldBJ(BlzGetUnitAbility(d, i), ABILITY_RLF_MOVEMENT_SPEED_INCREASE_PERCENT_BLO2, 0, increase);
		BlzSetAbilityRealLevelFieldBJ(BlzGetUnitAbility(d, i), ABILITY_RLF_DURATION_NORMAL, 0, duration);
		BlzSetAbilityRealLevelFieldBJ(BlzGetUnitAbility(d, i), ABILITY_RLF_DURATION_HERO, 0, duration);
		IssueTargetOrderById(d, 852101, u);
		RemoveUnit(d);
		u = null;
		d = null;
	}
	
}
//! endzinc