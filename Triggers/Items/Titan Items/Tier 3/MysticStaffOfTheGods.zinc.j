//! zinc
library MysticStaffOfTheGods requires ItemExtras {
    //Item ID
    private constant integer ITEM_ID = 'I01T';
    //Ability ID of the Far Sight ability
    private constant integer ABILITY_ID = 'A0CZ';
    //Ability ID of the true sight ability
    private constant integer TRUE_SIGHT = 'A0C1';
    //Timer speed to check the cooldown
    private constant real TIMER_SPEED = .5;
    //Hashtable I guess
    private hashtable st = InitHashtable();
    
    function checkCooldowns() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit u = LoadUnitHandle(st, 0, th);
        real cdRemaining = BlzGetUnitAbilityCooldownRemaining(u, ABILITY_ID);
        item tempItem = GetItemFromUnitById(u, ITEM_ID);
        integer aLvl = GetUnitAbilityLevel(u, TRUE_SIGHT);
        
        //BJDebugMsg("CD Remaining On MSOG: " + R2S(cdRemaining));
        if(UnitHasItemById(u, ITEM_ID)) {
            if(cdRemaining == 0 && aLvl == 0) {
                BlzItemAddAbility(tempItem, TRUE_SIGHT);
                FlushChildHashtable(st, th);
                DestroyTimer(t);
            }
        } else {
            BlzItemRemoveAbility(tempItem, TRUE_SIGHT);
            FlushChildHashtable(st, th);
            
            DestroyTimer(t);
        }
        
        t = null;
        u = null;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetTriggerUnit();
            timer t;
            integer th;
            item tempItem = GetItemFromUnitById(u, ITEM_ID);
            if(GetSpellAbilityId() == ABILITY_ID) {
                BlzItemRemoveAbility(tempItem, TRUE_SIGHT);
                t = CreateTimer();
                th = GetHandleId(t);
                
                SaveUnitHandle(st, 0, th, u);
                
                TimerStart(t, TIMER_SPEED, true, function checkCooldowns);
                t = null;
            }
            u = null;
            tempItem = null;
            return false;
        });
        t=null;
    }
    
}
//! endzinc
