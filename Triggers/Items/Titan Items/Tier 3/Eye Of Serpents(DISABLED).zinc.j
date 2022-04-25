//! zinc
library EyeofSerpents requires ItemExtras, BUM, MathLibs {
    //Item ID of Eye of Serpents
    private constant integer ITEM_ID = 'I07W';
    //Max charges of the item
    private constant integer MAX_CHARGES = 3;
    //Timer speed to constantly be checking for near gold mine and stuff
    private constant real TIMER_SPEED = .5;
    //Effect to play on recharge
    private constant string EFFECT = "";
    //AOE to detect gold mine
    private constant real AOE = 500;
    //Magic reduction
    private constant real MAGIC_REDUCE = .20;
    //Magic reduction while ethereal
    private constant real ETH_REDUCE = 1.0;
    //Buff ID of ethereal
    private constant integer BUFF_ID = 'BHbn';
    //Hashtable to store this bitch
    private hashtable serpTable = InitHashtable();
    
    function cleanUp(unit caster, timer t) {
        FlushChildHashtable(serpTable, GetHandleId(caster));
        FlushChildHashtable(serpTable, GetHandleId(t));
        
        DestroyTimer(t);
        t = null;
        caster = null;
    }
    
    function checkOwner() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit caster = LoadUnitHandle(serpTable, 0, th);
        integer ch = GetHandleId(caster);
        unit goldMine = getGoldMine();
        item i;
        
        //Caster is dead or non-existent or the unit lost the item
        if(caster == null || !UnitHasItemById(caster, ITEM_ID)) {
            cleanUp(caster, t);
        } else {
            i = GetItemFromUnitById(caster, ITEM_ID);
            if(getDistance(GetUnitX(caster), GetUnitY(caster), GetUnitX(goldMine), GetUnitY(goldMine)) <= AOE) {
                if(GetItemCharges(i) < MAX_CHARGES) {
                    SetItemCharges(i, MAX_CHARGES);
                }
            }
        }
        
        caster = null;
        t = null;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        onAcquireItem(t);
        onLoseItem(t);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetTriggerUnit();
            timer t = LoadTimerHandle(serpTable, 0, GetHandleId(u));
            integer th;
            if(GetItemTypeId(GetManipulatedItem()) == ITEM_ID) {
                if(UnitHasItemById(u, ITEM_ID)) {
                    if(t == null) {
                        t = CreateTimer();
                        th = GetHandleId(t);
                        SaveTimerHandle(serpTable, 0, GetHandleId(u), t);
                        SaveUnitHandle(serpTable, 0, th, u);
                        
                        TimerStart(t, TIMER_SPEED, true, function checkOwner);
                        
                        t = null;
                    }
                } else {
                    cleanUp(u, t);
                }
            }
            u = null;
            t = null;
            return false;
        });
        t = null;
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetTriggerUnit();
            damagetype d = BlzGetEventDamageType();
            
            if(UnitHasItemById(u, ITEM_ID)) {
                if(d == DAMAGE_TYPE_MAGIC) {
                    BlzSetEventDamage(GetEventDamage() * MAGIC_REDUCE);
                } else if(IsUnitType(u, UNIT_TYPE_ETHEREAL) || GetUnitAbilityLevel(u, BUFF_ID) > 0) {
                    BlzSetEventDamage(0);
                }
            }
            return false;
        });
    }
    
}
//! endzinc
        