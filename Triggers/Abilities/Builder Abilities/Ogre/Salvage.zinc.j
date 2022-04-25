//! zinc

library CatapultSalvage requires GT, xecast, xepreload {
    private constant integer ABILITY_ID = 'A0GF';
    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, ABILITY_ID);
        TriggerAddCondition(t , Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            player p = GetOwningPlayer(u);
            xecast xe = xecast.createBasicA('A0GG', OrderId("unsummon"), p);
            xe.recycledelay = 1.0;
            xe.setSourcePoint(GetUnitX(u), GetUnitY(u), 0.0);
            xe.castOnTarget(u);
            
            u = null;
            p = null;
            return false;
        }));
        XE_PreloadAbility(ABILITY_ID);
        t = null;
    }
}

//! endzinc