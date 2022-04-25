//! zinc
library FarseersStaff requires Apparition, DrawMagic {
    private constant integer ITEM_ID = 'I06P';
    private constant integer ABILITY_ID = 'A0I0';
    //This is both max mana to add if unit has buff AND mana to increase
    private constant integer MANA_ADD = 20; 
    private constant integer MANA_MAX = 5;
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, Condition(function()->boolean {
            unit a = GetEventDamageSource();
            unit t = GetTriggerUnit();
			boolean bestRestore = true;
            trigger tr = GetTriggeringTrigger();
		//Any other items with Draw Magic are better than this one.
		if(UnitHasItemById(a, 'I07W')) { //Has Crown of Depths
			bestRestore = false; }
		if(UnitHasItemById(a, 'I04P')) { //Has Crest of the Immortal
			bestRestore = false; }
		if(UnitHasItemById(a, 'I07S')) { //Foreteller's Sickle
			bestRestore = false; }
		if(UnitHasItemById(a, 'I02S')) { //Siren Scepter
			bestRestore = false; }

            if(UnitHasItemById(a, ITEM_ID) && !IsUnitAlly(t, GetOwningPlayer(a)) && bestRestore == true) {
                DisableTrigger(tr);
                onDrawMagicAttack(a, t, GetEventDamage(), MANA_ADD, MANA_MAX, true, false);
                EnableTrigger(tr);
            }
            a = null;
            t = null;
            tr = null;
            return false;
        }));
        t = null;
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, Condition(function()->boolean {
            unit caster;
            real tX;
            real tY;
            if(GetSpellAbilityId() == ABILITY_ID) {
                caster = GetTriggerUnit();
                tX = GetSpellTargetX();
                tY = GetSpellTargetY();
                CreateApparition(caster, tX, tY, false, 150, 150);
                caster = null;
            }
            return false;
        }));
    }
}
//! endzinc