//! zinc
library WatchersNecklace requires BonusMod, Scouting {
    //Item ID 
    private constant integer ITEM_ID = 'I06N';	//Watcher's Necklace
	private constant integer Dawnkeeper = 'I069';	//Dawnkeeper
    private constant integer RobeOfLies = 'I07K';	//Robe of Lies
    //Percentage of health healed on scouting ability
	private constant real HEAL_BONUS = 0.05;
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
			unit u = GetTriggerUnit();
			if(isScout(GetSpellAbilityId()) && UnitHasItemById(u, ITEM_ID) && !UnitHasItemById(u, Dawnkeeper) && !UnitHasItemById(u, RobeOfLies)) {
				addHealth(u, getMaxHealth(u) * HEAL_BONUS);
				DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIlm\\AIlmTarget.mdl", u, "origin"));
			}
			u = null;
            return false;
        });
        t=null;
    }
    
}
//! endzinc
