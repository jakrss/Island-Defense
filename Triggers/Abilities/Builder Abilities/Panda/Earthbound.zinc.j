//! zinc
library Earthbound {
	private hashtable linkHash = InitHashtable();
	private constant integer linkBuff = 'A0FD';
	private constant integer linkBuffPanda = 'A0FQ';
	private constant real duration = 8.00;

	function onDamage(unit Panda, unit a) {
		unit target = LoadUnitHandle(linkHash, 1, GetHandleId(Panda));
		real damage;
		lightning lightningx;
		if(GetUnitState(target, UNIT_STATE_LIFE) > 0) {
			damage = GetEventDamage();
			BlzSetEventDamage(0);
			UnitDamageTarget(a, target, damage, true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL ,WEAPON_TYPE_WHOKNOWS);
			lightningx = AddLightning( "SPLK", true, GetUnitX(Panda), GetUnitY(Panda), GetUnitX(target), GetUnitY(target));
			DestroyLightning(lightningx);
		} else {	//If the target is already dead, we can just call this all off:
			FlushChildHashtable(linkHash, GetHandleId(LoadTimerHandle(linkHash, 0, GetHandleId(Panda))));
			FlushChildHashtable(linkHash, GetHandleId(Panda));
			DestroyTimer(LoadTimerHandle(linkHash, 0, GetHandleId(Panda)));
			UnitRemoveAbility(Panda, linkBuffPanda);
			UnitRemoveAbility(target, linkBuff);
		}
		target = null;
		Panda = null;
		a = null;
	}

	function expiration() {
		timer t = GetExpiredTimer();
		unit Panda = LoadUnitHandle(linkHash, 0, GetHandleId(t));
		unit target = LoadUnitHandle(linkHash, 1, GetHandleId(Panda));
		FlushChildHashtable(linkHash, GetHandleId(t));
		FlushChildHashtable(linkHash, GetHandleId(Panda));
		DestroyTimer(LoadTimerHandle(linkHash, 0, GetHandleId(Panda)));
		UnitRemoveAbility(Panda, linkBuffPanda);
		UnitRemoveAbility(target, linkBuff);
		target = null;
		Panda = null;
	}

	function linkUnits() {
		unit Panda = GetTriggerUnit();
		unit linkTarget = GetSpellTargetUnit();
		timer t = CreateTimer();
		UnitAddAbility(linkTarget, linkBuff);
		UnitAddAbility(Panda, linkBuffPanda);
		SaveUnitHandle(linkHash, 0, GetHandleId(t), Panda);
		SaveTimerHandle(linkHash, 0, GetHandleId(Panda), t);
		SaveUnitHandle(linkHash, 1, GetHandleId(Panda), linkTarget);
		TimerStart(t, duration, false, function expiration);
	}

    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() {
            if(GetSpellAbilityId() == 'A0FC') {
                linkUnits();
            }
        });
        t = null;
		t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
		TriggerAddCondition(t, function() {
			unit u = GetTriggerUnit();
			unit a = GetEventDamageSource();
			if(GetUnitAbilityLevel(u, linkBuffPanda) > 0) {
				onDamage(u, a);
			}
			u = null;
		});
		t = null;
    }
}
//! endzinc