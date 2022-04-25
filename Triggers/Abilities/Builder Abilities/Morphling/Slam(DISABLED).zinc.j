//! zinc

library MorphlingSlam requires GT, xepreload, xecast {
    private constant integer ABILITY_ID = 'A04P';
    private constant real L1_DAMAGE_AMOUNT = 150.0;
    private constant real L2_DAMAGE_AMOUNT = 150.0;
    private constant real AREA = 500.0;
    private constant integer SLOW_ABILITY_ID = 'A04Q';
    
    private function checkTarget(unit caster, unit selected) -> boolean {
        return (!IsUnitAlly(selected, GetOwningPlayer(caster)) ||
                GetOwningPlayer(selected) == Player(PLAYER_NEUTRAL_PASSIVE)) &&
               !IsUnitType(selected, UNIT_TYPE_MAGIC_IMMUNE) &&
               !IsUnitType(selected, UNIT_TYPE_STRUCTURE) &&
               !IsUnitType(selected, UNIT_TYPE_MECHANICAL) &&
                UnitAlive(selected);
    }

    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, ABILITY_ID);
        TriggerAddCondition(t , Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            player p = GetOwningPlayer(u);
            unit v = null;
            group g = CreateGroup();
			integer level = GetUnitAbilityLevel(u, ABILITY_ID);
            xecast xe = 0;
            xedamage damage = xedamage.create();
			real d = L1_DAMAGE_AMOUNT;
			if (level > 1) {
				d = L2_DAMAGE_AMOUNT;
			}
           
            damage.dtype = DAMAGE_TYPE_MAGIC;
            damage.exception = UNIT_TYPE_STRUCTURE;
            
            GroupEnumUnitsInRange(g, GetUnitX(u), GetUnitY(u), AREA, null);
            
            v = FirstOfGroup(g);
            while (v != null) {
                if (checkTarget(u, v)) {
                    damage.damageTarget(u, v, d);
                    xe = xecast.createBasicA(SLOW_ABILITY_ID, OrderId("slow"), p); 
		    xe.level = level;
                    xe.recycledelay = 1.0;
                    xe.setSourcePoint(GetUnitX(u), GetUnitY(u), 0.0);
                    xe.castOnTarget(v);
                }
                GroupRemoveUnit(g, v);
                v = FirstOfGroup(g);
            }
           
            damage.destroy();
            DestroyGroup(g);
            g = null;
            u = null;
            v = null;
            p = null;
            return false;
        }));
        XE_PreloadAbility(ABILITY_ID);
        t = null;
    }
}

//! endzinc