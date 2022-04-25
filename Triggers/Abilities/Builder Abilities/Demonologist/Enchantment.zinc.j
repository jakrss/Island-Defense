//! zinc

library Enchantment requires GT {
    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'A0GT');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            real x = GetUnitX(u);
            real y = GetUnitY(u);
			integer id = 'I01D';
			
			if (GetUnitAbilityLevel(u, 'A0GT') > 1) {
				id = 'I03V';
			}
			
            UnitAddItem(u, CreateItem(id, x, y));
            DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\Unsummon\\UnsummonTarget.mdl", x, y));
            u = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc