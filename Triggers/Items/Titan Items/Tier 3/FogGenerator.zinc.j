//! zinc

library FogGenerator {
    private function CanHaveFog() -> boolean {
        return IsUnitType(GetFilterUnit(), UNIT_TYPE_HERO) == true;
    }

    private function tick() {
        group g = CreateGroup();
        boolexpr b = Condition(function CanHaveFog);
        unit u = null;
        
        GroupEnumUnitsInRect(g, GetWorldBounds(), b);
        DestroyBoolExpr(b);
        
        u = FirstOfGroup(g);
        while (u != null) {
            if (GetUnitAbilityLevel(u, 'B00L') > 0 &&   // Has Fog Generator Buff
                GetUnitAbilityLevel(u, 'A0MO') == 0)  	// Doesn't have invis at the moment
				{ UnitAddAbility(u, 'A0MO');
			} else if (GetUnitAbilityLevel(u,'B00L') == 0 && // If it lost the Fog Generator Buff
                     GetUnitAbilityLevel(u,'A0MO') > 0) {   	  // And has invis
                UnitRemoveAbility(u,'A0MO');
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
        TriggerRegisterTimerEvent(t, 0.50, true);
        TriggerAddAction(t, function tick);
        t = null;
    }
}

//! endzinc