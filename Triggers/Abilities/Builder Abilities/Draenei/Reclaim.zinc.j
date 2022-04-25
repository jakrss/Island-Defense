//! zinc

library DraeneiReclaim requires GT, xecast, xepreload {
    private constant integer ABILITY_ID = 'A03Y';
    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, ABILITY_ID);
        TriggerAddCondition(t , Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            player p = GetOwningPlayer(u);
            xecast xe = xecast.createBasicA('A042', OrderId("unsummon"), p);
            
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