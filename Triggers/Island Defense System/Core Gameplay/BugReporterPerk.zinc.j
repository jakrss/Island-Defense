//! zinc

library BugReporterPerk requires PerksSystem {
    private struct BetaPerk extends Perk {
        module PerkModule;
        private static constant integer GLOW_EFFECT_ITEM_ID = 'I05L';
        private static constant integer GLOW_EFFECT_ABILITY_ID = 'A0JJ';
        
        public method name() -> string {
            return "BetaPerk";
        }
        
        public method onSpawn(PlayerData p){
            Unit u = p.unit();
            unit v = null;
            if (u == 0) return;
            v = u.unit();
            UnitAddAbility(v, thistype.GLOW_EFFECT_ABILITY_ID);
            UnitMakeAbilityPermanent(v, true, thistype.GLOW_EFFECT_ABILITY_ID);
        }
        
        public method forPlayer(PlayerData p) -> boolean {
            string name = StringCase(p.name(), false);
             if(name == "" ||
		        name == "") return true;
            return false;
        }
        
        private static method initialize() {
            trigger t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER );
            TriggerAddCondition(t, function()->boolean {
                return (GetIssuedOrderId() > 852001 &&
                        GetIssuedOrderId() < 852008);
            });
            TriggerAddAction(t, function() {
                item it = GetOrderTargetItem();
                integer slotid = GetIssuedOrderId()-852002;
                unit u = GetOrderedUnit();
                integer id = GetItemTypeId(it);
                if (it == UnitItemInSlot(u, slotid) &&
                    id == thistype.GLOW_EFFECT_ITEM_ID){
                    // Hopefully persists
                    RemoveItem(it); // Need to remove item here, otherwise abilities clash and the next line won't work.
                    UnitAddAbility(u, thistype.GLOW_EFFECT_ABILITY_ID);
                    UnitMakeAbilityPermanent(u, true, thistype.GLOW_EFFECT_ABILITY_ID);
                }
                u = null;
                it = null;
            });
            t = null;
        }
    }
}
//! endzinc