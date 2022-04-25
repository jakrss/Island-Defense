//! zinc
library FieryTouch requires xefx, xebasic, xemissile, ItemExtras {
    //Library for Fiery Touch
    private hashtable fireTable = InitHashtable();
    //Timer speed for burning
    private constant real BURN_SPEED = 1;
    //Effect whenever burn damage is dealt
    private constant string BURN_EFFECT = "Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl";
    //Attack / Damage / Weapon type for dealing burn damage
    private constant attacktype AT = ATTACK_TYPE_NORMAL;
    private constant damagetype DT = DAMAGE_TYPE_UNIVERSAL;
    private constant weapontype WT = WEAPON_TYPE_WHOKNOWS;
    
    function cleanUp(timer t) {
        unit u = LoadUnitHandle(fireTable, 0, GetHandleId(t));
        unit d = LoadUnitHandle(fireTable, 1, GetHandleId(t));
        effect e = LoadEffectHandle(fireTable, 7, GetHandleId(t));
        DestroyEffect(e);
        FlushChildHashtable(fireTable, GetHandleId(u));
        FlushChildHashtable(fireTable, GetHandleId(d));
        FlushChildHashtable(fireTable, GetHandleId(t));
        
        DestroyTimer(t);
        u = null;
        d = null;
        e = null;
        t = null;
    }
    
    function burnBabyBurn() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit u = LoadUnitHandle(fireTable, 0, th);
        unit d = LoadUnitHandle(fireTable, 1, th);
        real DPS = LoadReal(fireTable, 2, th);
        real duration = LoadReal(fireTable, 3, th);
        real lowhp = LoadReal(fireTable, 4, th);
        real tCount = LoadReal(fireTable, 5, th);
        integer itemId = LoadInteger(fireTable, 6, th);
        
        real elapsedTime = tCount * BURN_SPEED;
        
        real percentLife = GetUnitState(d, UNIT_STATE_LIFE) / BlzGetUnitMaxHP(d);
        
        //If the owner dropped the item or the health is above the 20% and it's been longer than 5 seconds
        //OR finally if the unit is dead
        if(!UnitHasItemById(u, itemId) || (elapsedTime >= duration && percentLife > lowhp) || GetWidgetLife(d) < .405) {
            cleanUp(t);
        } else {
            UnitDamageTarget(u, d, DPS * BURN_SPEED, false, false, AT, DT, WT);
        }
        
        SaveReal(fireTable, 5, th, tCount + 1);
        
        u = null;
        d = null;
        t = null;
    }
    
    //Creates a new Fiery Touch instance of attacker, target, DPS, duration, and the %
    //of max HP to trigger constant burn (set to 0 to disable)
    public function FieryTouch(unit u, unit d, real DPS, integer itemId, real duration, real lowhp) {
        integer dh = GetHandleId(d);
        timer t = LoadTimerHandle(fireTable, 1, dh);
        integer th;
        effect e;
        boolean isLit = LoadBoolean(fireTable, 0, GetHandleId(d));
        if(!isLit && t == null) {
            t = CreateTimer();
            th = GetHandleId(t);
            e = AddSpecialEffectTarget(BURN_EFFECT, d, "origin");
            SaveUnitHandle(fireTable, 0, th, u);
            SaveUnitHandle(fireTable, 1, th, d);
            SaveReal(fireTable, 2, th, DPS);
            SaveReal(fireTable, 3, th, duration);
            SaveReal(fireTable, 4, th, lowhp); //Low HP % to continue burning (0 to disable)
            SaveReal(fireTable, 5, th, 0); // To count the Timer Loops
            SaveInteger(fireTable, 6, th, itemId);
            SaveEffectHandle(fireTable, 7, th, e);
            SaveBoolean(fireTable, 0, dh, true);
            SaveTimerHandle(fireTable, 1, dh, t);
            
            TimerStart(t, BURN_SPEED, true, function burnBabyBurn);
        } else if(t != null && isLit) {
            t = LoadTimerHandle(fireTable, 1, dh);
            th = GetHandleId(t);
            SaveReal(fireTable, 5, th, 0);
        } else if(t == null && isLit) {
            SaveBoolean(fireTable, 0, dh, false);
            FieryTouch(u, d, DPS, itemId, duration, lowhp);
        }
        
        t = null;
        u = null;
        d = null;
    }
    
}
//! endzinc
    