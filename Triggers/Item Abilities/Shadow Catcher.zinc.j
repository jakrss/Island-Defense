//! zinc

library ShadowCatcher {
    private function CanHaveShadow() -> boolean {
        return IsUnitType(GetFilterUnit(), UNIT_TYPE_HERO)==true;
    }
    
    private function tick() {
        group g = CreateGroup();
        boolexpr b = Filter(function CanHaveShadow);
        unit u = null;
        
        GroupEnumUnitsInRect(g, GetWorldBounds(), b);
        DestroyBoolExpr(b);
        
        u = FirstOfGroup(g);
        while (u != null) {
            if (GetUnitAbilityLevel(u, 'B026') > 0 &&   // Shadow Catcher Buff
                GetUnitAbilityLevel(u, 'A0BN') == 0 &&  // No Invis at the moment
                (GetUnitAbilityLevel(u, 'A0BN') == 0 && // ShadowCatcher
                 GetUnitAbilityLevel(u, 'TDA2') == 0 && // Demonicus Shadow Walk
                 GetUnitAbilityLevel(u, 'TDA3') == 0)) {
                UnitAddAbility(u, 'A0BN');
            }
            else if (GetUnitAbilityLevel(u,'B026') == 0 &&
                     GetUnitAbilityLevel(u,'A0BN') > 0) {
                UnitRemoveAbility(u,'A0BN');
            }
            GroupRemoveUnit(g, u);
            u = FirstOfGroup(g);
        }
        DestroyGroup(g);
        u = null;
        g = null;
        b = null;
    }

    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterTimerEvent(t, 1.00, true);
        TriggerAddAction(t, function tick);
        t = null;
    }
}

//! endzinc
