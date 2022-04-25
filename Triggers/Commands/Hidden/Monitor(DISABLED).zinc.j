//! zinc

library Monitor requires Table, Damage, AIDS, GameTimer {
    private Table monitoredUnits = 0;
    
    private struct MonitoredUnit {
        unit u;
        GameTimer expiry;
        real taken;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        Damage_RegisterEvent(t);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit a = GetEventDamageSource();
            unit u = GetTriggerUnit();
            real damage = GetEventDamage();
            integer id = GetUnitIndex(u);
            MonitoredUnit data = 0;
            
            if (GetUnitAbilityLevel(u, 'MARK') > 0) {
                if (!monitoredUnits.has(id)) {
                    BJDebugMsg("Registered " + GetUnitName(u));
                    data = MonitoredUnit.create();
                    data.u = u;
                    data.expiry = GameTimer.new(function(GameTimer t) {
                    });
                    data.expiry.setData(data);
                    data.expiry.start(99999.0);
                    data.taken = 0.0;
                    monitoredUnits[id] = data;
                }
                else {
                    data = monitoredUnits[id];
                }
                
                BJDebugMsg("Damage: " + R2S(damage) + " from " + GetUnitName(a));
                data.taken = data.taken + damage;
            }
            
            a = null;
            u = null;
            return false;
        }));
        t = CreateTrigger();
        GT_RegisterUnitDiesEvent(t, 'E00O');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetDyingUnit();
            integer id = GetUnitIndex(u);
            MonitoredUnit data = 0;
            
            if (monitoredUnits.has(id)) {
                data = monitoredUnits[id];
                BJDebugMsg(GetUnitName(u) + " has died. Took " + R2S(data.taken) + " damage over " + R2S(data.expiry.elapsed()) + "s.");
                data.destroy();
                monitoredUnits.remove(id);
            }
            
            u = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc