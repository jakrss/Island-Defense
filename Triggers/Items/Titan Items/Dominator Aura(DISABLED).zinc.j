//! zinc
library DominatorAura {
    private hashtable domTable = InitHashtable();
    
    function reduceLevel() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit u = LoadUnitHandle(domTable, 0, th);
        integer abilId = LoadInteger(domTable, 1, th);
        DecUnitAbilityLevel(u, abilId);
        
        FlushChildHashtable(domTable, th);
        FlushChildHashtable(domTable, GetHandleId(u));
        DestroyTimer(t);
    }
    
    public function domOnKill(unit u, integer domAbil, real DOMDUR) {
        timer t = LoadTimerHandle(domTable, 0, GetHandleId(u));
        if(t == null) {
            t = CreateTimer();
            SaveTimerHandle(domTable, 0, GetHandleId(u), t);
            
            SaveUnitHandle(domTable, 0, GetHandleId(t), u);
            SaveInteger(domTable, 1, GetHandleId(t), domAbil);
            
            IncUnitAbilityLevel(u, domAbil);
            TimerStart(t, DOMDUR, false, function reduceLevel);
        } else {
            FlushChildHashtable(domTable, GetHandleId(t));
            DestroyTimer(t);
            t = null;
            
            t = CreateTimer();
            SaveTimerHandle(domTable, 0, GetHandleId(u), t);
            
            SaveUnitHandle(domTable, 0, GetHandleId(t), u);
            SaveInteger(domTable, 1, domAbil, domAbil);
            
            TimerStart(t, DOMDUR, false, function reduceLevel);
        }
        t = null;
    }
}
//! endzinc