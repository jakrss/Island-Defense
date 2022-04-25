//! zinc
library GrimSpear requires ItemExtras, xecast, xefx, xebasic {
    //Item ID
    private constant integer ITEM_ID = 'I080';
    //Dark Touch stuff (lol)
    private constant real CHARGE_TIME = 40;
    //Max charges
    private constant integer MAX_CHARGES = 3;
    //Health healed
    private constant real HEAL = 100;
    //Ability ID of the Lance ability for the dummy unit to cast
    private constant integer ABILITY_ID = 'A001';
    //Effect to play on target when Lifestealing
    private constant string LIFESTEAL_EFFECT = "";
    //Buff ID of the lance ability
    private constant integer LANCE_BUFF = 'B066';
    //Hashtable
    private hashtable grimTable = InitHashtable();
    
    function cleanUp(unit u) {
        timer t = LoadTimerHandle(grimTable, 0, GetHandleId(u));
        
        FlushChildHashtable(grimTable, GetHandleId(u));
        FlushChildHashtable(grimTable, GetHandleId(t));
        
        DestroyTimer(t);
        
        t = null;
        u = null;
    }
    
    function updateCharges() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit u = LoadUnitHandle(grimTable, 0, th);
        integer charges = GetItemCharges(GetItemFromUnitById(u, ITEM_ID));
        
        if(charges < MAX_CHARGES) {
            charges = charges + 1;
            SetItemCharges(GetItemFromUnitById(u, ITEM_ID), charges);
        }
        if(!UnitHasItemById(u, ITEM_ID)) cleanUp(u);
        
        t = null;
        u = null;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetEventDamageSource();
            unit t = GetTriggerUnit();
            if(UnitHasItemById(u, ITEM_ID) && GetUnitAbilityLevel(t, LANCE_BUFF) > 0 && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {
                SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_LIFE) + HEAL);
                DestroyEffect(AddSpecialEffectTarget(LIFESTEAL_EFFECT, t, "origin"));
            }
            return false;
        });
        t=null;
        t = CreateTrigger();
        onAcquireItem(t);
        TriggerAddCondition(t, function() -> boolean {
            unit u;
            timer t;
            //Right item ID
            if(GetItemTypeId(GetManipulatedItem()) == ITEM_ID) {
                u = GetTriggerUnit();
                t = LoadTimerHandle(grimTable, 0, GetHandleId(u));
                
                //Unit has item so he picked it up
                if(UnitHasItemById(u, ITEM_ID)) {
                    if(t == null) {
                        //No timer was there though. So we start one to add charges.
                        t = CreateTimer();
                    
                        SaveUnitHandle(grimTable, 0, GetHandleId(t), u);
                        SaveTimerHandle(grimTable, 0, GetHandleId(u), t);
                        
                        TimerStart(t, CHARGE_TIME, true, function updateCharges);
                    }
                } else if(t != null && !UnitHasItemById(u, ITEM_ID)) {
                    cleanUp(u);
                }
            }
            return false;
        });
        t = null;
    }
    
}
//! endzinc
