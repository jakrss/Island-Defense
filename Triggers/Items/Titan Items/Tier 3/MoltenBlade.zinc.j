//! zinc
library MoltenBlade requires Emberhearth, FieryTouch, ItemExtras {
    //Item ID
    private constant integer ITEM_ID = 'I07L';
    //Duration of Emberhearth
    private constant real DURATION = 20;
    //Max charges / charge gen time
    private constant integer MAX_CHARGES = 2;
    private constant real CHARGE_TIME = 10;
    private constant string EFFECT = "Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl";
    //Burn stuff setup - DPS, Duration and HP Threshold
    private constant real DPS = 10;
    private constant real BURN_DURATION = 10;
    private constant real LOWHP = .20;
    private constant real AOE = 200;
    private constant real AOE_DAMAGE = 50;
    private constant real EXPLODE_TIME = 2.0;
    private hashtable moltenTable = InitHashtable();
    
    function checkExplosion(unit a, unit d, real damage) {
        group g;
        unit u;
        effect e;
        if(getHealth(d) <= damage) {
            DestroyEffect(AddSpecialEffectTarget(EFFECT, d, "origin"));
            g = CreateGroup();
            
            GroupEnumUnitsInRange(g, GetUnitX(d), GetUnitY(d), AOE, null);
            u = FirstOfGroup(g);
            
            while(u != null) {
                if(!IsUnitAlly(u, GetOwningPlayer(a))) {
                    UnitDamageTarget(a, u, AOE_DAMAGE, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_UNIVERSAL, WEAPON_TYPE_WHOKNOWS);
                    DestroyEffect(AddSpecialEffectTarget(EFFECT, u, "origin"));
                }
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            DestroyGroup(g);
            d = null;
            g = null;
        }
    }

    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, function() -> boolean {
            unit a = GetEventDamageSource();
            unit d = GetTriggerUnit();
            if(UnitHasItemById(a, ITEM_ID) && IsUnitType(d, UNIT_TYPE_STRUCTURE) && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {
                newEmberhearth(a, d, DURATION, MAX_CHARGES, CHARGE_TIME, ITEM_ID);
                FieryTouch(a, d, DPS, ITEM_ID, BURN_DURATION, LOWHP);
            }
	    if(UnitHasItemById(a, ITEM_ID) && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {
                checkExplosion(a, d, GetEventDamage());
            }
            d = null;
            a = null;
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
