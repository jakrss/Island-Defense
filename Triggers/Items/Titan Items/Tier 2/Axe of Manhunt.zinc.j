//! zinc
library AxeofManhunt requires ItemExtras, Manhunt {
    //Item ID for Axe of Manhunt
    private constant integer ITEM_ID = 'I06Z';
	private constant integer AXE_OF_SLAUGHTER_ID = 'I03H';
    //Duration of Manhunt
    private constant real MANHUNT_DUR = 20;
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, function () -> boolean {
            unit u = GetEventDamageSource();
            unit t = GetTriggerUnit();
	    if (!IsUnitType(t,UNIT_TYPE_STRUCTURE)) {
            if((UnitHasItemById(u, ITEM_ID) || UnitHasItemById(u, AXE_OF_SLAUGHTER_ID)) && !hasManhunt(t) && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {
                newManhunt(u, t, MANHUNT_DUR);
            }}
            u = null;
            t = null;
            return false;
        });
        t=null;
    }
    
}
//! endzinc