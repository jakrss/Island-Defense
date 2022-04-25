//! zinc
library WebPrison requires MathLibs {
	//Constants
	private constant integer Cast_Prison = 'A0M5';
	private constant integer Cast_Dummy = 'A0MA';
	private constant integer Cast_NestRage = 'A0MC';
	//Spell settings:
	private constant real AoE_Range = 300;
	private constant real Hunter_AR = 450;
	private constant real Rage_AR = 300;
	//Hashtable
	private hashtable RHash = InitHashtable();
	
	private function TimerExpiration() {
		timer t = GetExpiredTimer();
		unit c = LoadUnitHandle(RHash, GetHandleId(t), 0);
		BlzSetUnitWeaponRealFieldBJ(c, UNIT_WEAPON_RF_ATTACK_RANGE, 0, Hunter_AR);
		DestroyTimer(t);
		FlushChildHashtable(RHash, GetHandleId(c));
		FlushChildHashtable(RHash, GetHandleId(t));
		t = null;
		c = null;
	}
	
	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, function() {
			unit c;
			unit d;
			unit t;
			real facing;
			real tx = GetSpellTargetX();
			real ty = GetSpellTargetY();
			real x;
			real y;
			group g;
			integer level;
			timer ragetimer;
			real duration;
			//Web Prison
			if(GetSpellAbilityId() == Cast_Prison) {
				c = GetTriggerUnit();
				g = CreateGroup();
				level = GetUnitAbilityLevel(c, Cast_Prison);
				GroupEnumUnitsInRange(g, tx, ty, AoE_Range, null);
				//BJDebugMsg(I2S(CountUnitsInGroup(g)));
				t = FirstOfGroup(g);
				while(t != null) {
					if(IsUnitEnemy(c, GetOwningPlayer(t))) {
						x = GetUnitX(t);
						y = GetUnitY(t);
						facing = getAngle(tx, ty, x, y);
						d = CreateUnit(GetOwningPlayer(c), 'e01B', tx, ty, facing);
						UnitAddAbility(d, Cast_Dummy);
						SetUnitAbilityLevel(d, Cast_Dummy, level);
						IssueTargetOrderById(d, 852171, t);
						RemoveUnit(d);
					}
					GroupRemoveUnit(g, t);
					t = FirstOfGroup(g);
				}
			}
			DestroyGroup(g);
			g = null;
			c = null;
			//Nest Rage
			if(GetSpellAbilityId() == Cast_NestRage) {
				c = GetTriggerUnit();
				duration = GetUnitAbilityLevel(c, Cast_NestRage) * 7;
				if(TimerGetRemaining(LoadTimerHandle(RHash, GetHandleId(c), 0)) < duration) {
					BlzSetUnitWeaponRealFieldBJ(c, UNIT_WEAPON_RF_ATTACK_RANGE, 0, Hunter_AR + Rage_AR);
					ragetimer = CreateTimer();
					TimerStart(ragetimer, duration, false, function TimerExpiration);
					SaveUnitHandle(RHash, GetHandleId(ragetimer), 0, c);
					SaveTimerHandle(RHash, GetHandleId(c), 0, ragetimer);
				}
			}
		});
	}
}
//! endzinc