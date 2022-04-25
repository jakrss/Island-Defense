//! zinc
library RobeOfLies requires BonusMod, Scouting {
    //Item ID 
    private constant integer ITEM_ID = 'I07K';
    //Ability ID of the active
    private constant integer ABILITY_ID = 'A0LK';
	//Ability ID of the armor bonus
    private constant integer Ability_Armor = 'A0LP';
    //HP Bonus given
    private constant integer HP_REGEN = 650;
    //Mana bonus
    private constant integer MP_REGEN = 650;
    //Duration
    private constant real DURATION = 5.0;
    //Timer speed to restore stuff
    private constant real TIMER_SPEED = .1;
    //Percentage of health healed on scouting ability
	private constant real HEAL_BONUS = 0.08;
    //Hashtable
    private hashtable pmTable = InitHashtable();
	private hashtable EAHash = InitHashtable();
    
    function essenceTimer() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit caster = LoadUnitHandle(pmTable, 0, th);
        real numLoops = LoadReal(pmTable, 1, th);
        
        real hpRestore = (HP_REGEN / DURATION) * TIMER_SPEED;
        real mpRestore = (MP_REGEN / DURATION) * TIMER_SPEED;
        
        real health = GetUnitState(caster, UNIT_STATE_LIFE);
        real mana = GetUnitState(caster, UNIT_STATE_MANA);
        
        SetUnitState(caster, UNIT_STATE_LIFE, health + hpRestore);
        SetUnitState(caster, UNIT_STATE_MANA, mana + mpRestore);
        
        numLoops = numLoops + 1;
        if(numLoops * TIMER_SPEED > DURATION || GetWidgetLife(caster) < .405) {
            FlushChildHashtable(pmTable, th);
            
            DestroyTimer(t);
        } else {
            SaveReal(pmTable, 1, th, numLoops);
        }
        caster = null;
        t = null;
    }
    
    function onCast() {
        timer t = CreateTimer();
        integer th = GetHandleId(t);
        unit caster = GetTriggerUnit();
        real numLoops = 0;
        
        SaveUnitHandle(pmTable, 0, th, caster);
        SaveReal(pmTable, 1, th, numLoops);
        
        TimerStart(t, TIMER_SPEED, true, function essenceTimer);
        
        t =null;
        caster = null;
    }
	
	function ArmorHandler() {
		timer t = GetExpiredTimer();
		unit u = LoadUnitHandle(EAHash, GetHandleId(t), 0);
		effect e = LoadEffectHandle(EAHash, GetHandleId(u), 0);
		integer i = GetUnitAbilityLevel(u, Ability_Armor);
		DecUnitAbilityLevel(u, Ability_Armor);
		if(i == 2) {
			FlushChildHashtable(EAHash, GetHandleId(u));
			FlushChildHashtable(EAHash, GetHandleId(t));
			DestroyEffect(e);
			DestroyTimer(t);
		//Let's make the armor stacks disappear fast, but not instantly reset:			
		} else { TimerStart(t, 0.2, true, function ArmorHandler); }
		u = null;
		e = null;
		t = null;
	}
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
			unit u = GetTriggerUnit();
			integer i;
			timer t;
			if(UnitHasItemById(u, ITEM_ID)) {
				//Let's grant the bonus armor:
				i = GetUnitAbilityLevel(u, Ability_Armor);
				if(i < 6) { IncUnitAbilityLevel(u, Ability_Armor); }
				DestroyEffect(AddSpecialEffectTarget("", u, "origin"));
				if(i == 1) { 
					t = CreateTimer();
					SaveEffectHandle(EAHash, GetHandleId(u), 0, AddSpecialEffectTarget("Abilities\\Spells\\Human\\ManaShield\\ManaShieldCaster.mdl", u, "")); 
				} else { t = LoadTimerHandle(EAHash, GetHandleId(u), 1); }
				//Now store the timer, unit and begin the timer again.
				SaveUnitHandle(EAHash, GetHandleId(t), 0, u);
				SaveTimerHandle(EAHash, GetHandleId(u), 1, t);
				TimerStart(t, DURATION, true, function ArmorHandler);
				
				//Here ends armor part.
				if(GetSpellAbilityId() == ABILITY_ID) {
					onCast();
				}
				if(isScout(GetSpellAbilityId())) {
					addHealth(u, getMaxHealth(u) * HEAL_BONUS);
					DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIlm\\AIlmTarget.mdl", u, "origin"));
				}
			}
			u = null;
            return false;
        });
        t=null;
    }
    
}
//! endzinc
