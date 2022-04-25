//! zinc

library AvatarPoison requires GT, GameTimer, AIDS {
     private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'AHav');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            integer id = GetUnitIndex(u);
            UnitAddAbility(u,'Aspo');
            GameTimer.new(function(GameTimer t){
                unit u = GetIndexUnit(t.data());
                UnitRemoveAbility(u, 'Aspo');
                u = null;
            }).start(25.0).setData(id);
            u = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc