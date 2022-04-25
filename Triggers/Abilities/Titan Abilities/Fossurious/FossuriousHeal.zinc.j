//! zinc
library FossuriousHeal requires ABMA, BUM {
	//Handles duration of Fossurious' stealth as well as his Burrowing ability (heal).
	private constant integer aStealth = 'A0PZ';
	private constant integer aBurrowing = 'A0PY';
	private constant integer bBurrowedBuff = 'B07U';
	private constant real rNormalDuration = 8;
	private constant real rExtendDuration = 40;
	private constant real rHealInterval = 0.25;
	private constant real rHealAmount = 25;	//Per level
	private hashtable hBurrowed = InitHashtable();

    private function HealInterval() {
		timer tInterval = GetExpiredTimer();
		unit uFossurious = LoadUnitHandle(hBurrowed, GetHandleId(tInterval), 0);
		real rHeal = rHealAmount * GetUnitAbilityLevel(uFossurious, aBurrowing) * rHealInterval;
		healUnit(uFossurious, rHeal);
		tInterval = null;
		uFossurious = null;
	}
	
	private function AnimationPause() {
		timer tAnimation = GetExpiredTimer();
		unit uFossurious = LoadUnitHandle(hBurrowed, GetHandleId(tAnimation), 0);
		boolean bIsBurrowed = LoadBoolean(hBurrowed, GetHandleId(tAnimation), 1);
		if(bIsBurrowed) SetUnitTimeScalePercent(uFossurious, 0);
		if(!bIsBurrowed) {
			SetUnitTimeScalePercent(uFossurious, 100);
			SetUnitAnimation(uFossurious, "stand");
		}
		FlushChildHashtable(hBurrowed, GetHandleId(tAnimation));
		DestroyTimer(tAnimation);
		tAnimation = null;
	}
	
	private function onInit() {
		//Duration during Burrowing (utilizes Ability Manipulation:
		trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_CAST);
        TriggerAddCondition(t, function() -> boolean {
            unit uFossurious = GetTriggerUnit();
			boolean bIsBurrowed = LoadBoolean(hBurrowed, GetHandleId(uFossurious), 0);
			timer tInterval;
			real rHeal;
			if(bIsBurrowed == null) bIsBurrowed = false;
			if(GetSpellAbilityId() == aStealth && bIsBurrowed) ABMASetUnitAbilityDuration(uFossurious, aStealth, rExtendDuration);
			if(GetSpellAbilityId() == aStealth && !bIsBurrowed) ABMASetUnitAbilityDuration(uFossurious, aStealth, rNormalDuration);
			//Fossurious Burrowing:
			if(GetSpellAbilityId() == aBurrowing) {
				//If Fossurious is unburrowed (and burrows):
				if(!bIsBurrowed) {
					bIsBurrowed = true;
					tInterval = null;
					BlzUnitDisableAbility(uFossurious, 'Amov', true, false);
					BlzUnitDisableAbility(uFossurious, 'Aatk', true, false);
					//Pause animation upon finish:
					SetUnitTimeScalePercent(uFossurious, 84);
					tInterval = CreateTimer();
					TimerStart(tInterval, 1.00, false, function AnimationPause);
					SaveUnitHandle(hBurrowed, GetHandleId(tInterval), 0, uFossurious);
					SaveBoolean(hBurrowed, GetHandleId(tInterval), 1, bIsBurrowed);
					//Setup:
					SaveBoolean(hBurrowed, GetHandleId(uFossurious), 0, bIsBurrowed);
					tInterval = CreateTimer();
					TimerStart(tInterval, rHealInterval, true, function HealInterval);
					SaveUnitHandle(hBurrowed, GetHandleId(tInterval), 0, uFossurious);
					SaveTimerHandle(hBurrowed, GetHandleId(uFossurious), 1, tInterval);
                    ABMASetUnitAbilityManacost(uFossurious, aBurrowing, 0); 
				}
				//If Fossurious is burrowed (and unburrows):
				else if(bIsBurrowed) {
					bIsBurrowed = false;
					BlzUnitDisableAbility(uFossurious, 'Amov', false, false);
					BlzUnitDisableAbility(uFossurious, 'Aatk', false, false);
					//Return his animation speed:
					SetUnitTimeScalePercent(uFossurious, 15);
					tInterval = CreateTimer();
					TimerStart(tInterval, 0.75, false, function AnimationPause);
					SaveUnitHandle(hBurrowed, GetHandleId(tInterval), 0, uFossurious);
					SaveBoolean(hBurrowed, GetHandleId(tInterval), 1, bIsBurrowed);
					//Setup:
					SaveBoolean(hBurrowed, GetHandleId(uFossurious), 0, bIsBurrowed);
					tInterval = LoadTimerHandle(hBurrowed, GetHandleId(uFossurious), 1);
					FlushChildHashtable(hBurrowed, GetHandleId(tInterval));
					DestroyTimer(tInterval);
					rHeal = getMaxHealth(uFossurious) * (0.05 + 0.05 * GetUnitAbilityLevel(uFossurious, aBurrowing));
					healUnit(uFossurious, rHeal);
					FlushChildHashtable(hBurrowed, GetHandleId(uFossurious));
					UnitRemoveAbility(uFossurious, bBurrowedBuff);
                    ABMASetUnitAbilityManacost(uFossurious, aBurrowing, 200);
				}
			}
            uFossurious = null;
			tInterval = null;
            return false;
        });
		t = null;
    }
}

//! endzinc