//! zinc

library WarStomp requires GT, xepreload, UnitStatus {
    private constant integer ABILITY_ID = 'A04F';
    private constant real DAMAGE_AMOUNT = 175.0;
    private constant real AREA = 250.0;
    private constant real STUN_DURATION = 1.0;
    
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
            xedamage damage = xedamage.create();
            damage.dtype = DAMAGE_TYPE_MAGIC;
            damage.exception = UNIT_TYPE_STRUCTURE;
            
            GroupEnumUnitsInRange(g, GetUnitX(u), GetUnitY(u), AREA, null);
            
            v = FirstOfGroup(g);
            while (v != null) {
                if (checkTarget(u, v)) {
                    damage.damageTarget(u, v, DAMAGE_AMOUNT);
                    StunUnitTimed(v, STUN_DURATION);
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