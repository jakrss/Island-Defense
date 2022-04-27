//! zinc
library BurningOil {
	private constant integer aBurningOil = 'A0H2';
	private constant real tick = 0.20;
	private constant real duration = 2;
	private constant integer dmg_per_lvl = 25;
	private hashtable burnHash = InitHashtable();
	private hashtable shieldHash = InitHashtable();

	function tickTimerTick() {
		timer tickTimer = GetExpiredTimer();
		unit target = LoadUnitHandle(burnHash, GetHandleId(tickTimer), 0);
		unit Panda = LoadUnitHandle(burnHash, GetHandleId(tickTimer), 1);
		integer lvl = LoadInteger(burnHash, GetHandleId(tickTimer), 2);
		real damage = (lvl * dmg_per_lvl)*(tick/duration);
		boolean onFire;
				if(lvl==1) damage = 5;
				if(lvl==2) damage = 10;
				if(lvl==3) damage = 20;
				if(lvl==4) damage = 40;
				if(lvl==5) damage = 80;
		if(GetUnitAbilityLevel(target, 'B07G') > 0) {
			UnitDamageTarget(Panda, target, damage, true, false, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS);
		} else {
			FlushChildHashtable(burnHash, GetHandleId(tickTimer));
			DestroyTimer(tickTimer);
			onFire = false;
			SaveBoolean(burnHash, GetHandleId(target), 0, onFire);
			Panda = null;
			target = null;
		}
	}

    private function onInit() {
        trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
		TriggerAddCondition(t, function() {
			unit target = GetTriggerUnit();
			unit attacker = GetEventDamageSource();
			integer burningOilLevel;
			real damage;
			timer tickTimer;
			boolean onFire = LoadBoolean(burnHash, GetHandleId(target), 0);
			if(GetUnitAbilityLevel(attacker, aBurningOil) >= 0 && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {
				burningOilLevel = GetUnitAbilityLevel(attacker, aBurningOil);
				if(burningOilLevel==1) damage = 5;
				if(burningOilLevel==2) damage = 10;
				if(burningOilLevel==3) damage = 20;
				if(burningOilLevel==4) damage = 40;
				if(burningOilLevel==5) damage = 80;
				UnitDamageTarget(attacker, target, damage, true, false, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS);		
				BlzSetEventDamage(GetEventDamage() * (1+(damage/1000)));	//Increase incoming damage by %.
				if(onFire == false) {
					onFire = true;
					tickTimer = CreateTimer();
					//TimerStart(tickTimer, tick, true, function tickTimerTick);
					SaveUnitHandle(burnHash, GetHandleId(tickTimer), 0, target);
					SaveUnitHandle(burnHash, GetHandleId(tickTimer), 1, attacker);
					SaveInteger(burnHash, GetHandleId(tickTimer), 2, burningOilLevel);
					SaveBoolean(burnHash, GetHandleId(target), 0, onFire);
				}
			}
			target = null;
			attacker = null;
			tickTimer = null;
		});
		t = null;
    }
}
//! endzinc


