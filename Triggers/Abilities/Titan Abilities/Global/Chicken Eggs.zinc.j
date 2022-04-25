//! zinc

library ChickenEggs requires GT, CreateItemEx {
    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterUnitDiesEvent(t, 'n00C');
        TriggerAddCondition( t, Condition(function() -> boolean {
            unit u = GetDyingUnit();
            CreateItemEx('I022', GetUnitX(u), GetUnitY(u));
            u = null;
            return false;
        }));
        t = CreateTrigger();
        GT_RegisterUnitDiesEvent(t, 'n018');
        TriggerAddCondition( t, Condition(function() -> boolean {
            unit u = GetDyingUnit();
            CreateItemEx('I022', GetUnitX(u), GetUnitY(u));
            CreateItemEx('I022', GetUnitX(u) + 20.0,
                               GetUnitY(u) + 20.0);
            u = null;
            return false;
        }));
        t = CreateTrigger();
        GT_RegisterUnitDiesEvent(t, 'n019');
        TriggerAddCondition( t, Condition(function() -> boolean {
            unit u = GetDyingUnit();
            CreateItemEx('I022', GetUnitX(u), GetUnitY(u));
            CreateItemEx('I022', GetUnitX(u) + 20.0,
                               GetUnitY(u) + 20.0);
            CreateItemEx('I022', GetUnitX(u) - 20.0,
                               GetUnitY(u) - 20.0);
            u = null;
            return false;
        }));
    }
}

//! endzinc
