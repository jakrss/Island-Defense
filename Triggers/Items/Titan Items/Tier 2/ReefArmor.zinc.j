//! zinc
library ReefArmor requires ItemExtras {
    //Item ID for Reef Armor
    private constant integer ITEM_ID = 'I041';
    //Item ID for Armor of Tides
    private constant integer ITEM_ID_S = 'I06E';
    //Amount of damage to reduce
    private constant real DMG_REDUCTION = .02;

    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, function() -> boolean {
            unit damaged = GetTriggerUnit();
            real damage = GetEventDamage();
            if((UnitHasItemById(damaged, ITEM_ID) || UnitHasItemById(damaged, ITEM_ID_S)) && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {
                BlzSetEventDamage(damage * (1 - DMG_REDUCTION));
            }
            damaged = null;
            return false;
        });
        t=null;
    }
	
}
//! endzinc