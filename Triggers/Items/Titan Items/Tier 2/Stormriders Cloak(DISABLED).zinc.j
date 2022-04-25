//! zinc
library StormridersCloak requires BonusMod, ItemExtras {
    //Item ID for Stormriders Cloak
    private constant integer ITEM_ID = 'I06M';
    //Buff for Shadow Walk
    private constant integer BUFF_ID = 'BOwk';
    //Sight range bonus
    private constant integer SIGHT_BONUS = 200;
    //Night time bonus
    private constant real MOVE_BONUS = .12;
    //Timer to check time of day
    private constant real TIMER_SPEED = 1.0;
    //Amount to multiply move bonus by when Shadow Walk'd
    private constant integer MOVE_MULT = 2;
    //Hashtable
    private hashtable scT = InitHashtable();
    
    function checkTime() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit owner = LoadUnitHandle(scT, 0, th);
        real ownerMs = LoadReal(scT, 1, th);
        real currentMs = GetUnitMoveSpeed(owner);
        real moveBonus = 1 + MOVE_BONUS;
        real tod = GetTimeOfDay();
        
        //Add in a self destroy
        if(!UnitHasItemById(owner, ITEM_ID)) {
            AddUnitBonus(owner, BONUS_SIGHT_RANGE, -1 * SIGHT_BONUS);
            DestroyTimer(t);
            FlushChildHashtable(scT, th);
        } else {
            
            if(GetUnitAbilityLevel(owner, BUFF_ID) > 0) moveBonus = 1 + (MOVE_BONUS * MOVE_MULT);
            
            if(tod <= 6 && tod >= 18) {
                if(currentMs <= ownerMs * (1 + MOVE_BONUS)) {
                    SetUnitMoveSpeed(owner, ownerMs * (1 + MOVE_BONUS));
                }
            } else {
                if(currentMs >= ownerMs) {
                    SetUnitMoveSpeed(owner, ownerMs);
                }
            }
        }
        t = null;
        owner = null;
        
    }
    
    function onPickup() {
        unit owner = GetTriggerUnit();
        timer t = CreateTimer();
        integer th = GetHandleId(t);
        real ownerMs = GetUnitMoveSpeed(owner);
        
        SaveUnitHandle(scT, 0, th, owner);
        SaveReal(scT, 1, th, ownerMs);
        
        AddUnitBonus(owner, BONUS_SIGHT_RANGE, SIGHT_BONUS);
        
        TimerStart(t, TIMER_SPEED, true, function checkTime);
        
        t = null;
        owner = null;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        onAcquireItem(t);
        TriggerAddCondition(t, function() -> boolean {
            unit owner = GetTriggerUnit();
            integer itemId = GetItemTypeId(GetManipulatedItem());
            if(itemId == ITEM_ID) {
                onPickup();
            }
            owner = null;
            return false;
        });
        t=null;
    }
    
}
//! endzinc