//! zinc
library RobeofLies requires ItemExtras, BUM, Scouting, BonusMod, MathLibs {
    //Item ID for Robe of Lies
    private constant integer ITEM_ID = 'I07K';
    private constant integer ARMOR_BONUS = 10;
    private constant real DURATION = 4.00;
    private constant real HEALTH = .10;
    private constant real HEAL = 1500;
    private constant real MANA = 750;
    private constant real SCOUT_HEAL = .15;
    private constant real COOLDOWN = 120;
    //Speed of the timer on the cooldown checking for Gold Mine basically
    private constant real CD_TIMER = 1.0;
    private hashtable rolTable = InitHashtable();
    
    function onExpire() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit u = LoadUnitHandle(rolTable, 0, th);
        integer armorRemove = -1 * LoadInteger(rolTable, 1, th);
        
        AddUnitBonus(u, BONUS_ARMOR, armorRemove);
        
        FlushChildHashtable(rolTable, th);
        DestroyTimer(t);
        u = null;
        t = null;
    }
    
    //Casting any ability increases armor
    function onCast() {
        unit u = GetTriggerUnit();
        integer uh = GetHandleId(u);
        timer t = CreateTimer();
        integer th = GetHandleId(t);
        
        AddUnitBonus(u, BONUS_ARMOR, ARMOR_BONUS);
        
        SaveUnitHandle(rolTable, 0, th, u);
        SaveInteger(rolTable, 0, th, ARMOR_BONUS);
        
        TimerStart(t, DURATION, false, function onExpire);
        
        u = null;
        t = null;
    }
    
    function cdTimer() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit u = LoadUnitHandle(rolTable, 0, th);
        real cdRemain = LoadReal(rolTable, 0, GetHandleId(u));
        real distance = getDistance(GetUnitX(u), GetUnitY(u), GetUnitX(getGoldMine()), GetUnitY(getGoldMine()));
        
        if(cdRemain < 1 || distance < 400) {
            DestroyTimer(t);
            FlushChildHashtable(rolTable, th);
            FlushChildHashtable(rolTable, GetHandleId(u));
            //DestroyEffect(AddSpecialEffectTarget(CD_EFFECT, u, "origin"));
        } else {
            cdRemain = cdRemain - CD_TIMER;
            SaveReal(rolTable, 0, GetHandleId(u), cdRemain);
        }
        t = null;
        u = null;
    }
    
    //Restore health on below, start timer and check for goldmine
    function onBelowHealth(unit u) {
        timer t = CreateTimer();
        integer th = GetHandleId(t);
        
        addHealth(u, HEAL);
        addMana(u, MANA);
        
        SaveUnitHandle(rolTable, 0, th, u);
        SaveReal(rolTable, 0, GetHandleId(u), COOLDOWN);
        
        TimerStart(t, CD_TIMER, true, function cdTimer);
        
        u = null;
        t = null;
    }
    
    function checkHealth() {
        timer t = GetExpiredTimer();
        unit u = LoadUnitHandle(rolTable, 0, GetHandleId(t));
        if(!UnitHasItemById(u, ITEM_ID)) {
            FlushChildHashtable(rolTable, GetHandleId(t));
            DestroyTimer(t);
        }
        if((getHealth(u) / getMaxHealth(u)) <= HEALTH) onBelowHealth(u);
        t = null;
        u = null;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        onAcquireItem(t);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetTriggerUnit();
            timer t = LoadTimerHandle(rolTable, 1, GetHandleId(u));
            if(UnitHasItemById(u, ITEM_ID) && t == null) {
                t = CreateTimer();
                SaveUnitHandle(rolTable, 0, GetHandleId(t), u);
                
                TimerStart(t, CD_TIMER, true, function checkHealth);
                t = null;
            }
            
            return false;
        });
        t = null;
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetTriggerUnit();
            if(UnitHasItemById(u, ITEM_ID)) {
                onCast();
            }
            u = null;
            return false;
        });
        t=null;
    }
}
//! endzinc