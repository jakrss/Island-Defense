//! zinc

library NetherJump requires xecast, GT {
    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'A0BL');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            unit v = GetSpellTargetUnit();
            xecast cast = xecast.createBasicA('A0BM', OrderId("darksummoning"), GetOwningPlayer(u));
            
            cast.setSourcePoint(GetUnitX(v), GetUnitY(v), 0.0);
            cast.castOnPoint(GetUnitX(u), GetUnitY(u));
            u = null;
            v = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc