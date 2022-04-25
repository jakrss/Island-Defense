//! zinc

library EditorPerk requires PerksSystem {
    private struct EditorPerk extends Perk {
        module PerkModule;
        private static constant integer GLOW_EFFECT_ABILITY_ID = 'A0P1';
        
        public method name() -> string {
            return "EditorPerk";
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
            if (name == "iamdragon" || 
                name == "remixer" ||
		name == "jakers#1978") return true;
            return false;
        }
        
        private static method initialize() {
            trigger t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER );
            TriggerAddCondition(t, function()->boolean {
                return (GetIssuedOrderId() > 852001 &&
                        GetIssuedOrderId() < 852008);
            });
            t = null;
        }
    }
}
//! endzinc