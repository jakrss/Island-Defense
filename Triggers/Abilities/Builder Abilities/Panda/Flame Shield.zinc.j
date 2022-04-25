//! zinc
library AflameShield {
	private hashtable shieldHash = InitHashtable();
	private constant boolean sendDebug = false;


    private function onInit() {
        trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
		TriggerAddCondition(t, function() {
			unit target = GetTriggerUnit();
			unit attacker = GetEventDamageSource();
			real damage = GetEventDamage();
			real shield;
			real balance;
			trigger tr = GetTriggeringTrigger();
			//Fire Form Enflame shield:
			DisableTrigger(tr);
			if(GetUnitAbilityLevel(attacker, 'B05X') > 0 && IsUnitEnemy(attacker, GetOwningPlayer(target)) == true && damage > 0) {
				BJDebugMsg("|cffccff00Damage dealt: " + R2S(damage));
				shield = LoadReal(shieldHash, GetHandleId(attacker), 0);
				shield = shield + (damage * (0.25 + (0.25 * GetUnitAbilityLevel(attacker, 'A0FO'))));
				if(shield > 250 * GetUnitAbilityLevel(attacker, 'A0FO')) {
					shield = 250 * GetUnitAbilityLevel(attacker, 'A0FO');
					if(sendDebug) BJDebugMsg("|cff00ee00Maximum shield overflow!");
				} else {
					if(sendDebug) BJDebugMsg("|cff00ee00Shield value: " + R2S(shield));
				}
				SaveReal(shieldHash, GetHandleId(attacker), 0, shield);
			}
			if(GetUnitAbilityLevel(target, 'B05X') > 0 && LoadReal(shieldHash, GetHandleId(target), 0) > 0 && damage > 0) {
				if(sendDebug) BJDebugMsg("|cffccff00Damage taken: " + R2S(damage));
				shield = LoadReal(shieldHash, GetHandleId(target), 0);
				if(sendDebug) BJDebugMsg("|cffcc0000Damage taken, current shield: |r" + R2S(shield));
				balance = shield - damage;
				if(balance >= 0) {
					shield = balance;
					BlzSetEventDamage(0);
					if(sendDebug) BJDebugMsg("|cff00cc00New shield value: |r" + R2S(shield));
				} else if(balance < 0) {
					BlzSetEventDamage(damage - shield);
					if(sendDebug) BJDebugMsg("|cffff0000Shield breaks!");
					shield = 0;
				}
				SaveReal(shieldHash, GetHandleId(target), 0, shield);
			}
			EnableTrigger(tr);
			target = null;
			attacker = null;
		});
		t = null;
    }
}
//! endzinc