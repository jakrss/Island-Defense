//! zinc

library FireworksItem requires xecast, GT, GameTimer {
    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterItemUsedEvent(t, 'I04J');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            player p = GetOwningPlayer(u);
            xecast xe = xecast.createBasic('A0GE', OrderId("starfall"), p);
            xe.recycledelay = 5.1;
            xe.castInPoint(GetUnitX(u), GetUnitY(u));
            
            GameTimer.new(function(GameTimer t){
                xecast xe = t.data();
                xe.destroy();
            }).start(5.1).setData(xe);
            
            p = null;
            u = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc