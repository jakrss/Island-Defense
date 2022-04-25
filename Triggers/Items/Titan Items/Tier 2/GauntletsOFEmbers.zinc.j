//! zinc
library GauntletsOfEmbers requires BonusMod, ItemExtras, xebasic, xemissile, xefx, Emberhearth, FieryTouch {
    //Item ID
    private constant integer ITEM_ID = 'I04Z';
    //% health where it won't wear off
    private constant real HEALTH = .20;
    //DPS
    private constant real DPS = 8;
    //Duration
    private constant real DURATION = 12.0;
    //Timer speed for burning
    private constant real TIMER_SPEED = 1;
    //Vision Ability for the flames to provide vision
    private constant integer VISION_ABILITY = 'ABCi';
    //Max charges
    private constant integer MAX_CHARGES = 2;
    //Charge generation time
    private constant real CHARGE_TIME = 10;
    //Spark (Fiery) model path (or dummy unit)
    private constant string MISSILE_MODEL = "SparksMissile.mdx";
    //Sparks duration
    private constant real EMBER_DURATION = 20;
    
    function onDamage() {
        unit attacker = GetEventDamageSource();
        unit damaged = GetTriggerUnit();
        
        newEmberhearth(attacker, damaged, EMBER_DURATION, MAX_CHARGES, CHARGE_TIME, ITEM_ID);
        FieryTouch(attacker, damaged, DPS, ITEM_ID, DURATION, HEALTH);
        
        damaged = null;
        attacker = null;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, function() -> boolean {
            unit attacker = GetEventDamageSource();
            unit damaged = GetTriggerUnit();
            if(UnitHasItemById(attacker, ITEM_ID) && IsUnitType(damaged, UNIT_TYPE_STRUCTURE) && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {
                onDamage();
            }
            damaged = null;
            attacker = null;
            return false;
        });
        t=null;
        t = CreateTrigger();
        onAcquireItem(t);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetTriggerUnit();
            if(GetItemTypeId(GetManipulatedItem()) == ITEM_ID) {
                onPickupEmber(u, ITEM_ID, CHARGE_TIME, MAX_CHARGES);
            }
            u = null;
            return false;
        });
        t=null;
    }
    
}
//! endzinc
