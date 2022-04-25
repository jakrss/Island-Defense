//! zinc
library EssenceOfPureMagic requires BonusMod {
    //Item ID 
    private constant integer ITEM_ID = 'I07H';
    //Ability ID of the active
    private constant integer ABILITY_ID = 'A0IY';
    //HP Bonus given
    private constant integer HP_REGEN = 1000;
    //Mana bonus
    private constant integer MP_REGEN = 1000;
    //Duration
    private constant real DURATION = 4.0;
    //Timer speed to restore stuff
    private constant real TIMER_SPEED = .1;
    //Hashtable
    private hashtable pmTable = InitHashtable();
    
    function essenceTimer() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit caster = LoadUnitHandle(pmTable, 0, th);
        real numLoops = LoadReal(pmTable, 1, th);
        
        real hpRestore = (HP_REGEN / DURATION) * TIMER_SPEED;
        real mpRestore = (MP_REGEN / DURATION) * TIMER_SPEED;
        
        real health = GetUnitState(caster, UNIT_STATE_LIFE);
        real mana = GetUnitState(caster, UNIT_STATE_MANA);
        
        SetUnitState(caster, UNIT_STATE_LIFE, health + hpRestore);
        SetUnitState(caster, UNIT_STATE_MANA, mana + mpRestore);
        
        numLoops = numLoops + 1;
        if(numLoops * TIMER_SPEED > DURATION || GetWidgetLife(caster) < .405) {
            FlushChildHashtable(pmTable, th);
            
            DestroyTimer(t);
        } else {
            SaveReal(pmTable, 1, th, numLoops);
        }
        caster = null;
        t = null;
    }
    
    function onCast() {
        timer t = CreateTimer();
        integer th = GetHandleId(t);
        unit caster = GetTriggerUnit();
        real numLoops = 0;
        
        SaveUnitHandle(pmTable, 0, th, caster);
        SaveReal(pmTable, 1, th, numLoops);
        
        TimerStart(t, TIMER_SPEED, true, function essenceTimer);
        
        t =null;
        caster = null;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
            if(GetSpellAbilityId() == ABILITY_ID) {
                onCast();
            }
            return false;
        });
        t=null;
    }
    
}
//! endzinc
