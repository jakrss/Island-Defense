//! zinc
library Regen requires BUM, ItemExtras {
    hashtable regenTable = InitHashtable();
    private real TIMER_SPEED = .5;
    
    public function hasRegenTimer(unit u) -> boolean {
        return LoadTimerHandle(regenTable, 0, GetHandleId(u)) != null;
    }
    
    function checkRegen() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit u = LoadUnitHandle(regenTable, 0, th);
        real amount = LoadReal(regenTable, 1, th);
        real percentCond = LoadReal(regenTable, 2, th);
        integer itemId = LoadItemHandle(regenTable, 3, th);
        boolean hp = LoadBoolean(regenTable, 4, th);
        real curHP = getHealth(u);
        real curMP = getMana(u);
        real maxHP = getMaxHealth(u);
        real maxMP = getMaxMana(u);
        
        if(UnitHasItemById(u, itemId)) {
            if(hp) {
                if((curHP / maxHP) <= percentCond) {
                    if(amount < 1 && amount > 0) {
                        
                    }
                }
            }
        } else {
            FlushChildHashtable(regenTable, GetHandleId(u));
            FlushChildHashtable(regenTable, th);
            DestroyTimer(t);
        }
        t = null;
        u = null;
    }
    
    //Note if amount is > 0 and less than 1 it'll be treated as percentage of max
    //HP is a boolean whether it's HP or mana
    public function activateRegenItem(unit u, boolean hp, real amount, real percentCond, integer itemId) {
        //TO DO - Create a timer, check for whatever the condition is
        timer t = CreateTimer();
        integer th = GetHandleId(t);
        
        SaveTimerHandle(regenTable, 0, GetHandleId(u), t);
        
        SaveUnitHandle(regenTable, 0, th, u);
        SaveReal(regenTable, 1, th, amount);
        SaveReal(regenTable, 2, th, percentCond);
        SaveInteger(regenTable, 3, th, itemId);
        SaveBoolean(regenTable, 4, th, hp);
        TimerStart(t, TIMER_SPEED, true, function checkRegen);
        
        t = null;
        u = null;
        i = null;
    }
}
//! endzinc