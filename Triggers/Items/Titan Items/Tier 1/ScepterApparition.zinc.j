//! zinc
library ScepterApparition requires Apparition, DrawMagic {
    private constant integer ITEM_ID = 'I05Q';
    private constant integer ABILITY_ID = 'A0EV';
    //This is both max mana to add if unit has buff AND mana to increase
    private constant integer MANA_ADD = 3;
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, Condition(function()->boolean {
            unit a = GetEventDamageSource();
            unit t = GetTriggerUnit();
	    boolean bestRestore = true;
            trigger tr = GetTriggeringTrigger();
		//Other items with Draw Magic that are better than this one.
	   	if(UnitHasItemById(a, 'I06P')) { //Has Farseer's Staff
			bestRestore = false; }
		if(UnitHasItemById(a, 'I06T')) { //Has Summoner's Wrist Guard
			bestRestore = false; }
		if(UnitHasItemById(a, 'I04P')) { //Has Crest of the Immortal
			bestRestore = false; }
		if(UnitHasItemById(a, 'I07W')) { //Has Crown of Depths
			bestRestore = false; }
		if(UnitHasItemById(a, 'I07S')) { //Has Foreteller's Sickle
			bestRestore = false; }
		if(UnitHasItemById(a, 'I02S')) { //Has Siren Scepter
			bestRestore = false; }

            if(UnitHasItemById(a, ITEM_ID) && !IsUnitAlly(t, GetOwningPlayer(a)) && bestRestore == true) {
                DisableTrigger(tr);
                onDrawMagicAttack(a, t, GetEventDamage(), MANA_ADD, MANA_ADD, true, false);
                EnableTrigger(tr);
            }
            tr = null;
            a = null;
            t = null;
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
                CreateApparition(caster, tX, tY, true, 60, 500);
                caster = null;
            }
            return false;
        }));
        t = null;
    }
}
//! endzinc