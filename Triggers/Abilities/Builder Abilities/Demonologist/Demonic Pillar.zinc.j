//! zinc

library DemonicPillar {
    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterEnterRectSimple(t, GetWorldBounds());
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetEnteringUnit();
            if (GetUnitTypeId(u) == 'h034'){
                UnitApplyTimedLife(u, 'BTLF', 8.00);
            }
            u = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc