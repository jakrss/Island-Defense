//! zinc
library SuperRegenSpines requires BonusMod, ItemExtras, BUM {
    //Item ID of Super Regenerative Spines
    private constant integer ITEM_ID = 'I01Q';
    //Decimal percentage of max health regained per second when under 60%
    private constant real P_LIFE = .01;
    //Ability ID
    private constant integer ABILITY_ID = 'A0K9';
    //Health regen provided by the item
    private constant integer REGEN = 8;
    //Health percentage to add REGEN health regen to unit
    private constant real LIFE = 60;
    //Timer speed to check HP
    private constant real TIMER_SPEED = .50;
    //Hashtable to check life percent to shut off the regen effect
    private hashtable srsT = InitHashtable();
    
    function regenPercent(unit u, real curHP, real maxHP) {
		if(GetUnitAbilityLevel(u, ABILITY_ID) != 1) {
            UnitAddAbilityBJ(ABILITY_ID, u);
	    //BJDebugMsg("Super Regen != 1, so adding regen");
        }
    }
    
    function checkHealth() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit u = LoadUnitHandle(srsT, 0, th);
        item i = LoadItemHandle(srsT, 1, th);
        real curHP = getHealth(u);
        real maxHP = getMaxHealth(u);
        
        
        if(UnitHasItemById(u, ITEM_ID)) {
            if((curHP/maxHP) <= (LIFE / 100)) {
                regenPercent(u, curHP, maxHP);
            } else {
                if(GetUnitAbilityLevel(u, ABILITY_ID) == 1) {
                    UnitRemoveAbilityBJ(ABILITY_ID, u);
		    //BJDebugMsg("Super regen = 1, so taking it away");
                }
            }
        } else {
            FlushChildHashtable(srsT, GetHandleId(i));
            FlushChildHashtable(srsT, th);
            DestroyTimer(t);
        }
        u = null;
        i = null;
        t = null;
    }
    
    function onPickup() {
        unit u = GetTriggerUnit();
        item i = GetManipulatedItem();
        timer t = CreateTimer();
        integer th = GetHandleId(t);
        
        if(LoadTimerHandle(srsT, 0, GetHandleId(i)) != null) {
            //No timer exists so we start one
            FlushChildHashtable(srsT, GetHandleId(LoadTimerHandle(srsT, 0, GetHandleId(i))));
            DestroyTimer(LoadTimerHandle(srsT, 0, GetHandleId(i)));
        }
        
        SaveUnitHandle(srsT, 0, th, u);
        SaveItemHandle(srsT, 1, th, i);
        SaveTimerHandle(srsT, 0, GetHandleId(i), t);
        
        TimerStart(t, TIMER_SPEED, true, function checkHealth);
        
        i = null;
        u = null;
        t = null;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        onAcquireItem(t);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetTriggerUnit();
            item i = GetManipulatedItem();
            if(GetItemTypeId(i) == ITEM_ID) {
                onPickup();
            }
            u = null;
            i = null;
            return false;
        });
        t = null;
        t = CreateTrigger();
        onLoseItem(t);
        TriggerAddCondition(t, function() -> boolean {
	    unit u = GetTriggerUnit();
            item i = GetManipulatedItem();
            timer t = LoadTimerHandle(srsT, 0, GetHandleId(i));
	    if(GetItemTypeId(i) == ITEM_ID) {
	    UnitRemoveAbilityBJ(ABILITY_ID, u); }
            if(t != null) {
                FlushChildHashtable(srsT, GetHandleId(t));
                FlushChildHashtable(srsT, GetHandleId(i));
                DestroyTimer(t);
            }
            u = null;
            i = null;
            t = null;
            return false;
        });
        t = null;
    }
}
//! endzinc