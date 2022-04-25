//! zinc

library Bones requires GT, CreateItemEx {
    private constant integer MinionBonesUnit = 'MBOU';
    private constant integer MinionBonesHero = 'MBOH';
    private constant integer TitanBonesUnit  = 'TBOU';
    private constant integer TitanBonesHero  = 'TBOH';
    
    private function swapUnitItem(unit u, item it, integer new) {
        item n = CreateItemEx(new, GetUnitX(u), GetUnitY(u));
        RemoveItem(it);
        UnitAddItem(u, n);
    }

    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterItemAcquiredEvent(t, MinionBonesUnit);
        GT_RegisterItemAcquiredEvent(t, MinionBonesHero);
        GT_RegisterItemAcquiredEvent(t, TitanBonesUnit);
        GT_RegisterItemAcquiredEvent(t, TitanBonesHero);
        TriggerAddAction(t, function(){
            item it = GetManipulatedItem();
            integer i = GetItemTypeId(it);
            unit u = GetTriggerUnit();
            
            if (IsUnitType(u, UNIT_TYPE_HERO) == false){
                if (i == MinionBonesHero) {
                    swapUnitItem(u, it, MinionBonesUnit);
                }
                else if (i == TitanBonesHero) {
                    swapUnitItem(u, it, TitanBonesUnit);
                }
            }
            else {
                if (i == MinionBonesUnit) {
                    swapUnitItem(u, it, MinionBonesHero);
                }
                else if (i == TitanBonesUnit) {
                    swapUnitItem(u, it, TitanBonesHero);
                }
            }
            u = null;
            it = null;
        });
        t = null;
    }
}

//! endzinc