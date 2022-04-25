//! zinc
library ForetellersSickle requires Apparition, DrawMagic, MathLibs, ItemExtras, BUM {
    //Item ID
    private constant integer ITEM_ID = 'I07S';
    //active ability ID
    private constant integer ABILITY_ID = 'A0I0';
    //Apparition buff
    private constant integer BUFF_ID = 'B04L';
    //Range of the missile
    private constant real RANGE = 3500;
    //Time they're marked for
    private constant real VISION_TIME = 60.0;
    //AOE of the vision area
    private constant real IMPACT_VISION = 700;
    //Duration of the impact vision area
    private constant real IMPACT_DURATION = 60.0;
    //Mana to add permanently on killing something with the apparition buff
    private constant integer PERM_MANA = 5;
    //Mana to restore on killing something
    private constant real MANA_RESTORE = 50;
    
    function onCast() {
        unit caster = GetTriggerUnit();
        real tX = GetSpellTargetX();
        real tY = GetSpellTargetY();
        
        CreateApparition(caster, tX, tY, false, VISION_TIME, IMPACT_VISION);
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
            if(GetSpellAbilityId() == ABILITY_ID) {
                onCast();
            }
            return false;
        });
        t=null;
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
			TriggerAddCondition(t, function() -> boolean {
				unit attacker = GetEventDamageSource();
				unit target = GetTriggerUnit();
				real damage = GetEventDamage();
			boolean bestRestore = true;
				trigger tr = GetTriggeringTrigger();
			//Other items with Draw Magic that are better than this one.
			if(UnitHasItemById(attacker, 'I04P')) { //Has Crest of the Immortal
				bestRestore = false; }

				if(UnitHasItemById(attacker, ITEM_ID) && !IsUnitAlly(target, GetOwningPlayer(attacker)) && bestRestore) {
					DisableTrigger(tr);
					onDrawMagicAttack(attacker, target, GetEventDamage(), MANA_RESTORE, PERM_MANA, true, false);
					EnableTrigger(tr);
				}
			attacker = null;
			target = null;
			tr = null;
			return false;
			});
		t = null;
	}
}
//! endzinc
