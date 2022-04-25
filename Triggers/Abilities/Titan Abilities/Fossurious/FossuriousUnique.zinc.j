//! zinc
library FossuriousUnique requires ABMA, BUM, MathLibs {
	//Handles duration of Fossurious' stealth as well as his Burrowing ability (heal).
	private constant integer aUnique = 'A0Q0';
	private constant integer uCryptTunnel = 'e01E';
	private constant real rEffectDistance = 74;
	private constant string sEffect = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl";
	private hashtable hTunneling = InitHashtable();
	
	private function SpawnEffect(real x, real y) {
		effect eNew = AddSpecialEffect(sEffect, x-GetRandomReal(-80,80), y-GetRandomReal(-80,80));
		real rRandom = GetRandomReal(0.80,1.65);
		location lLocation = Location(x,y);
		BlzSetSpecialEffectScale(eNew, rRandom);
		rRandom = GetLocationZ(lLocation) + GetRandomReal(-5,40);
		BlzSetSpecialEffectHeight(eNew, rRandom);
		RemoveLocation(lLocation);
		lLocation = null;
		DestroyEffect(eNew);
	}
	
	private function FinishCast() {
		timer tInterval = GetExpiredTimer();
		unit uFossurious = LoadUnitHandle(hTunneling, GetHandleId(tInterval), 0);
		real x = LoadReal(hTunneling, GetHandleId(tInterval), 1);
		real y = LoadReal(hTunneling, GetHandleId(tInterval), 2);
		integer c = 0;
		SetUnitPosition(uFossurious, x, y);
		while(c < 9) {
			SpawnEffect(x, y);
			c += 1;
		}
		SetUnitAnimation(uFossurious, "morph defend");
		FlushChildHashtable(hTunneling, GetHandleId(tInterval));
		uFossurious = null;
		tInterval = null;
	}
	
	private function EffectLoop() {
		timer tInterval = GetExpiredTimer();
		unit uFossurious = LoadUnitHandle(hTunneling, GetHandleId(tInterval), 0);
		real rEffectNumber = LoadReal(hTunneling, GetHandleId(tInterval), 1);
		real xEffect = LoadReal(hTunneling, GetHandleId(tInterval), 2);
		real yEffect = LoadReal(hTunneling, GetHandleId(tInterval), 3);
		real xTarget = LoadReal(hTunneling, GetHandleId(tInterval), 4);
		real yTarget = LoadReal(hTunneling, GetHandleId(tInterval), 5);
		rEffectNumber -= 1;
		SaveReal(hTunneling, GetHandleId(tInterval), 1, rEffectNumber);
		if(rEffectNumber >= 0) {
			xEffect = offsetXTowardsPoint(xEffect, yEffect, xTarget, yTarget, rEffectDistance);
			yEffect = offsetYTowardsPoint(LoadReal(hTunneling, GetHandleId(tInterval), 2), yEffect, xTarget, yTarget, rEffectDistance);
			SaveReal(hTunneling, GetHandleId(tInterval), 2, xEffect);
			SaveReal(hTunneling, GetHandleId(tInterval), 3, yEffect);
			SpawnEffect(xEffect, yEffect);
		} else {
			SetUnitAnimation(uFossurious, "morph");
			CreateUnit(GetOwningPlayer(uFossurious), uCryptTunnel, GetUnitX(uFossurious), GetUnitY(uFossurious), GetUnitFacing(uFossurious));
			FlushChildHashtable(hTunneling, GetHandleId(tInterval));
			DestroyTimer(tInterval);
			tInterval = null;
			tInterval = CreateTimer();
			TimerStart(tInterval, 1, false, function FinishCast);
			SaveUnitHandle(hTunneling, GetHandleId(tInterval), 0, uFossurious);
			SaveReal(hTunneling, GetHandleId(tInterval), 1, xTarget);
			SaveReal(hTunneling, GetHandleId(tInterval), 2, yTarget);
		}
		uFossurious = null;
		tInterval = null;
	}
	
	private function isTunnel() -> boolean {
		if(GetUnitTypeId(GetFilterUnit()) == uCryptTunnel) {
			return true;
		} else {
			return false;
		}
	}
	
	private function onInit() {
		//Duration during Burrowing (utilizes Ability Manipulation:
		trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_CHANNEL);
        TriggerAddCondition(t, function() -> boolean {
            unit uFossurious = GetTriggerUnit();
			group gTunnel;
			integer iUniqueLevel;
			timer tInterval;
			real rDuration;
			real rXTarget;
			real rYTarget;
			real rXCaster;
			real rYCaster;
			real rEffectNumber;
			real rEffectInterval;
			if(GetSpellAbilityId() == aUnique) {
				rXCaster = GetUnitX(uFossurious);
				rYCaster = GetUnitY(uFossurious);
				rXTarget = GetSpellTargetX();
				rYTarget = GetSpellTargetY();
				gTunnel = CreateGroup();
				GroupEnumUnitsInRange(gTunnel, rXCaster, rYCaster, 125, function isTunnel);
				if(CountUnitsInGroup(gTunnel) == 0) {
					iUniqueLevel = GetUnitAbilityLevel(uFossurious, aUnique);
					tInterval = CreateTimer();
					rEffectNumber = R2I(getDistance(rXCaster, rYCaster, rXTarget, rYTarget) / rEffectDistance);
					if(iUniqueLevel == 1) { rEffectInterval = 19 / rEffectNumber; 
					} else if(iUniqueLevel == 2) rEffectInterval = 4 / rEffectNumber;
					SaveUnitHandle(hTunneling, GetHandleId(tInterval), 0, uFossurious);
					SaveReal(hTunneling, GetHandleId(tInterval), 1, rEffectNumber);
					SaveReal(hTunneling, GetHandleId(tInterval), 2, rXCaster);
					SaveReal(hTunneling, GetHandleId(tInterval), 3, rYCaster);
					SaveReal(hTunneling, GetHandleId(tInterval), 4, rXTarget);
					SaveReal(hTunneling, GetHandleId(tInterval), 5, rYTarget);
					TimerStart(tInterval, rEffectInterval, true, function EffectLoop);
				} else {
					SetUnitAnimation(uFossurious, "morph");
					tInterval = CreateTimer();
					TimerStart(tInterval, 1, false, function FinishCast);
					SaveUnitHandle(hTunneling, GetHandleId(tInterval), 0, uFossurious);
					SaveReal(hTunneling, GetHandleId(tInterval), 1, rXTarget);
					SaveReal(hTunneling, GetHandleId(tInterval), 2, rYTarget);
				}
			}
			DestroyGroup(gTunnel);
			gTunnel = null;
            uFossurious = null;
			tInterval = null;
            return false;
        });
		t = null;
    }
}

//! endzinc