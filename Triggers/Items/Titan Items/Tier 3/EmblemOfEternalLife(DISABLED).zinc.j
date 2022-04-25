//! zinc
library EmblemOfEternalLife requires Scouting, ItemExtras {
    //Item ID
    private constant integer ITEM_ID = 'I07U';
    //Ability ID
    private constant integer ABILITY_ID = 'A0HR';
    //Amount of mana refunded and CD refunded
    private constant real MANA_REFUNDED = .50;
    private constant real CD_REFUNDED = .25;
    //Ability levels to increase the summons by
    private constant integer ABILITY_INC = 10;
    
    // function getSummonAbility(unit u) -> integer {
    //    if(GetUnitAbilityLevel(u, 'TMAD') > 0) {
    //        return 'TMAD';
    //    } else if(GetUnitAbilityLevel(u, 'TTAD') > 0) {
    //        return 'TTAD';
    //    }
    //    return 0;
    //}
    
    //function onChangeEmblem() {
    //    unit u = GetTriggerUnit();
    //    //integer abilityId = getSummonAbility(u);
    //    integer aLvl;
    //    integer itemId = GetItemTypeId(GetManipulatedItem());
    //    
    //    if(abilityId != 0) {
    //        if(UnitHasItemById(u, itemId)) {
    //            aLvl = GetUnitAbilityLevel(u, abilityId);
    //            SetUnitAbilityLevel(u, abilityId, aLvl + ABILITY_INC);
    //        } else {
    //            aLvl = GetUnitAbilityLevel(u, abilityId);
    //            SetUnitAbilityLevel(u, abilityId, 1);
    //        }
    //    }
    //}
    
    private function onInit() {
        trigger t = CreateTrigger();
        onAcquireItem(t);
        onLoseItem(t);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetTriggerUnit();
            if(GetItemTypeId(GetManipulatedItem()) == ITEM_ID) {
                onChangeEmblem();
            }
            u = null;
            return false;
        });
        t=null;
    }
    
}
//! endzinc
