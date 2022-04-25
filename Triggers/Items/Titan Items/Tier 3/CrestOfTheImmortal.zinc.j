//! zinc
library CrestOfTheImmortal requires BonusMod, Scouting, ItemExtras, DrawMagic, Healing {
    //Item ID 
    private constant integer ITEM_ID = 'I04P';
    //Amount to restore per attack
    private constant integer MANA_RESTORE = 25;
    //Amount to add permanently on killing units
    private constant integer MANA_ADD = 5;
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, function() -> boolean {
            unit attacker = GetEventDamageSource();
            unit dyer = GetTriggerUnit();
            integer spellId = GetSpellAbilityId();
            trigger tr = GetTriggeringTrigger();
			boolean bestRestore = true;
			//Other items with Draw Magic that are better than this one.
			if(UnitHasItemById(attacker, 'I02S')) { //Siren Scepter
				bestRestore = false;
			}
            if(UnitHasItemById(attacker, ITEM_ID) && !IsUnitAlly(dyer, GetOwningPlayer(attacker))) {
                DisableTrigger(tr);
                onDrawMagicAttack(attacker, dyer, GetEventDamage(), MANA_RESTORE, MANA_ADD, false, true);
                EnableTrigger(tr);
            }
            attacker = null;
            dyer = null;
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
