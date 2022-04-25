//! zinc
library CrownOf requires ItemExtras, DrawMagic, Healing {
	//Item ID for Summoners Wristguard
	private constant integer ITEM_ID = 'I07W';
	//Amount of mana to restore on attack
	private constant real MANA_RESTORE = 15;
	//Amount of mana to add permanently on killing something
	private constant integer MANA_ADD = 5;
	//Effect on mana heal
	private constant string EFFECT = "Abilities\\Spells\\Items\\Alma\\AlmaTarget.mdl";
        
	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
		TriggerAddCondition(t, function() -> boolean {
		    unit attacker = GetEventDamageSource();
		    unit target = GetTriggerUnit();
            	    trigger tr = GetTriggeringTrigger();
	   	    boolean bestRestore = true;
		//Other items with Draw Magic that are better than this one.
		if(UnitHasItemById(attacker, 'I02S')) { //Siren Scepter
			bestRestore = false; }
		if(UnitHasItemById(attacker, 'I07S')) { //Foreteller's Sickle
			bestRestore = false; }
		if(UnitHasItemById(attacker, 'I04P')) { //Has Crest of the Immortal
			bestRestore = false; }
			
		    if(UnitHasItemById(attacker, ITEM_ID) && !IsUnitAlly(target, GetOwningPlayer(attacker)) && bestRestore == true) {
                        DisableTrigger(tr);
		        onDrawMagicAttack(attacker, target, GetEventDamage(), MANA_RESTORE, MANA_ADD, false, true);
                        EnableTrigger(tr);
		    }
		    target = null;
		    attacker = null;
                    tr = null;
		    return false;
		});
		t=null;
                t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, function() -> boolean {
		    unit caster = GetTriggerUnit();
                    
		    if(UnitHasItemById(caster, ITEM_ID) && isHeal(GetSpellAbilityId())) {
                        insightHeal(caster, .06, 0);
		    }
		    return false;
		});
		t=null;
	}
	
}
//! endzinc