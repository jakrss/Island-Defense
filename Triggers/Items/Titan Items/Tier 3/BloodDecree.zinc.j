//! zinc
library BloodDecree requires ItemExtras, BonusMod, BUM {
    //Item ID
    private constant integer ITEM_ID = 'I07I';
    //Ability ID for Massacre
    private constant integer ABILITY_ID = 'MSCR';
    //Duration of the ability
    private constant real DURATION = 5.0;
    //Attack damage increase
    private constant real DMG_INC = 10;
    //Duration of the attack damage increase
    private constant real DMG_DURATION = 8.0;
    //HP Threshold
    private constant real HP_AMT = .15;
    //Low hp multiplier
    private constant integer HP_MULT = 4;
    //Add blood effect
    private constant string EFFECT = "Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl";
    //Hashtable
    private hashtable bdTable = InitHashtable();
    
    function cleanUp() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit u = LoadUnitHandle(bdTable, 0, th);
        
        SaveBoolean(bdTable, 0, GetHandleId(u), false);
        
        FlushChildHashtable(bdTable, GetHandleId(u));
        FlushChildHashtable(bdTable, th);
        DestroyTimer(t);
        
        t = null;
        u = null;
    }
    
    function damageExpire() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit u = LoadUnitHandle(bdTable, 0, th);
        integer uh = GetHandleId(u);
        
        real dmgChange = -1 * LoadReal(bdTable, 1, th);
        AddUnitBonus(u, BONUS_DAMAGE, R2I(dmgChange));
        
        FlushChildHashtable(bdTable, th);
        DestroyTimer(t);
        u = null;
        t = null;
    }
    
    function onDamage() {
        unit u = GetEventDamageSource();
        timer t = CreateTimer();
        integer uh = GetHandleId(u);
        integer th = GetHandleId(t);
        
        real percentHealth = getRatioHealth(u);
        real dmgInc = DMG_INC;
        
        if(percentHealth <= HP_AMT) {
            dmgInc = dmgInc * HP_MULT;
        }
        
        AddUnitBonus(u, BONUS_DAMAGE, R2I(dmgInc));
        
        SaveUnitHandle(bdTable, 0, th, u);
        SaveReal(bdTable, 1, th, I2R(R2I(dmgInc)));
	
        TimerStart(t, DMG_DURATION, false, function damageExpire);
        
        DestroyEffect(AddSpecialEffectTarget(EFFECT, u, "chest"));
        
        t = null;
        u = null;
    }
    
    function onCast() {
        timer t;
        integer th;
        unit u = GetTriggerUnit();
        
        if(!LoadBoolean(bdTable, 0, GetHandleId(u))) {
            t = CreateTimer();
            th = GetHandleId(t);
            SaveUnitHandle(bdTable, 0, th, u);
            
            SaveBoolean(bdTable, 0, GetHandleId(u), true);
            SaveReal(bdTable, 1, GetHandleId(u), 0);
            
            TimerStart(t, DURATION, false, function cleanUp);
        }
        t = null;
        u = null;
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
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, function() -> boolean {
            unit a = GetEventDamageSource();
            if(LoadBoolean(bdTable, 0, GetHandleId(a)) && UnitHasItemById(a, ITEM_ID) && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {
                onDamage();
            }
			a = null;
            return false;
        });
    }
	
}
//! endzinc
