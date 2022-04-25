//! zinc
library GazeOfRage requires ItemExtras, BonusMod, BUM {
    //Item ID
    private constant integer ITEM_ID = 'I07P';
    //Ability ID (Active)
    private constant integer ABILITY_ID = 'A0JB';
    //Ability ID of the damage increase ability that the active gives
    private constant integer DMG_ID = 'A0J3';
    //Duration of the DMG increase
    private constant real DMG_DUR = 4.0;
    //Ability ID of the Armor Bonus
    private constant integer ARMOR_ID = 'A0IZ';
    //Ability ID of the AS Bonus
    private constant integer ASPEED_ID = 'A0J0';
    //Ability ID of the HP Regen
    private constant integer HP_REGEN_ID = 'A0J1';
    //Ability ID of the Movespeed Ability
    private constant integer MS_ID = 'A0J2';
    //Percentage of Max HP to double stats
    private constant real HP_THRESHOLD = .5;
    //Timer speed to check for updates on health
    private constant real TIMER_SPEED = .25;
    //Hashtable
    private hashtable gazeTable = InitHashtable();
    
    function cleanUp(unit u, timer t) {
        boolean curBonus = LoadBoolean(gazeTable, 1, GetHandleId(t));
        
        if(curBonus) {
            SetUnitAbilityLevel(u, ARMOR_ID, 1);
            SetUnitAbilityLevel(u, ASPEED_ID, 1);
            SetUnitAbilityLevel(u, HP_REGEN_ID, 1);
            SetUnitAbilityLevel(u, MS_ID, 1);
        }
        
        FlushChildHashtable(gazeTable, GetHandleId(u));
        FlushChildHashtable(gazeTable, GetHandleId(t));
        
        DestroyTimer(t);
        t = null;
        u = null;
    }
    
    function onChange() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit u = LoadUnitHandle(gazeTable, 0, th);
        real curLife = GetUnitState(u, UNIT_STATE_LIFE);
        real maxLife = BlzGetUnitMaxHP(u);
        real percentLife = curLife / maxLife;
        boolean curBonus = LoadBoolean(gazeTable, 1, th);
        //curBonus is whether or not the bonus is currently active
        
        if(!UnitHasItemById(u, ITEM_ID)) {
            cleanUp(u, t);
        } else if(percentLife <= HP_THRESHOLD && !curBonus) {
            //Great let's boost him
            SetUnitAbilityLevel(u, ARMOR_ID, 2);
            SetUnitAbilityLevel(u, ASPEED_ID, 2);
            SetUnitAbilityLevel(u, HP_REGEN_ID, 2);
            SetUnitAbilityLevel(u, MS_ID, 2);
            
            SaveBoolean(gazeTable, 1, th, true);
        } else if(percentLife >= HP_THRESHOLD && curBonus) {
            SetUnitAbilityLevel(u, ARMOR_ID, 1);
            SetUnitAbilityLevel(u, ASPEED_ID, 1);
            SetUnitAbilityLevel(u, HP_REGEN_ID, 1);
            SetUnitAbilityLevel(u, MS_ID, 1);
            
            SaveBoolean(gazeTable, 1, th, false);
        }
    }
	
    private function onInit() {
        trigger t = CreateTrigger();
        onAcquireItem(t);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetTriggerUnit();
            timer t = LoadTimerHandle(gazeTable, 0, GetHandleId(u));
            integer th = GetHandleId(t);
            if(UnitHasItemById(u, ITEM_ID)) {
                //Timer is null so he has no active timers
                if(t == null) {
                    t = CreateTimer();
                    th = GetHandleId(t);
                    
                    SaveTimerHandle(gazeTable, 0, GetHandleId(u), t);
                    
                    SaveUnitHandle(gazeTable, 0, th, u);
                    //Save whether it's active right now or not
                    SaveBoolean(gazeTable, 1, th, false);
                    
                    TimerStart(t, TIMER_SPEED, true, function onChange);
                    
                    t = null;
                }
            } else {
                cleanUp(u, t);
            }
            u = null;
            t = null;
            return false;
        });
        t=null;
    }
    
}
//! endzinc
