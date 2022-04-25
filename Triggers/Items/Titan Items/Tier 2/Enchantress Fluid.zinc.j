//! zinc
library EnchantressFluid requires BonusMod, BUM {
	//Item ID for Enchant
	private constant integer ITEM_ID = 'I06V';
	private constant integer ACTIVE_ID = 'A08D';
	//Duration for the active ability (caster gets 300 mana over the next 3 seconds )
	//Armor increase for the shared duration
	private constant real ACTIVE_DURATION = 3.0;
	private constant real MANA_RESTORED = 300;
	private constant real TIMER_SPEED = .5;
	private hashtable enchantTable = InitHashtable();
	
	function endInstance(timer periodicTimer) {
		integer timerHandle = GetHandleId(periodicTimer);
		unit caster = LoadUnitHandle(enchantTable, 0, timerHandle);
		caster = null;
		FlushChildHashtable(enchantTable, timerHandle);
		DestroyTimer(periodicTimer);
	}
	
	function restoreMana() {
		timer periodicTimer = GetExpiredTimer();
		integer timerHandle = GetHandleId(periodicTimer);
		unit caster = LoadUnitHandle(enchantTable, 0, timerHandle);
		real loopsRun = LoadReal(enchantTable, 1, timerHandle);
		real curDuration = loopsRun * TIMER_SPEED;
		real MANA_TO_ADD = (MANA_RESTORED / ACTIVE_DURATION) * TIMER_SPEED;
		real currentMana = getMana(caster);
                
		if(curDuration > ACTIVE_DURATION) {
			endInstance(periodicTimer);
		} else {
			loopsRun = loopsRun + 1;
			addMana(caster, MANA_TO_ADD);
			SaveReal(enchantTable, 1, timerHandle, loopsRun);
		}
	}
	
	function onCast(unit caster) {
		timer periodicTimer = CreateTimer();
		integer timerHandle = GetHandleId(periodicTimer);
		integer casterHandle = GetHandleId(caster);
		real loopsRun = 0;

		TimerStart(periodicTimer, TIMER_SPEED, true, function restoreMana);
		
		SaveUnitHandle(enchantTable, 0, timerHandle, caster);
		SaveReal(enchantTable, 1, timerHandle, loopsRun);

		periodicTimer = null;
		
	}

	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, function() -> boolean {
			if(GetSpellAbilityId() == ACTIVE_ID) {
				onCast(GetTriggerUnit());
			}
			return false;
		});
		t=null;
	}
	
}
//! endzinc