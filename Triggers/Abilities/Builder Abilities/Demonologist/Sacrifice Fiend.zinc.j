//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library SelfSacrifice requires GT {
    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'A0BJ');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            real x = GetUnitX(u);
            real y = GetUnitY(u);

            UnitAddAbility(u, 'S00F');
            UnitApplyTimedLife(u, 'BTLF', 8.0);
            DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl", x, y));

            u = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc