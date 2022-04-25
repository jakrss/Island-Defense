//! zinc

library PolarWrath requires GT, GameTimer, AIDS, BonusMod, UnitMaxState {
     private function onInit(){
		// Removes the Magnataur's ability to gold while it has Polar Fury/Wrath/Vengeance
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'A04H');
        GT_RegisterStartsEffectEvent(t, 'A07I');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            integer id = GetUnitIndex(u);
            UnitRemoveAbility(u, 'A041');
            GameTimer.newPeriodic(function(GameTimer t){
                unit u = GetIndexUnit(t.data());
                // NOTE(Neco): Using "BHav" here instead of Polar Wrath's buff
                //             as it is hardcoded into WC3 to use BHav.
                if (GetUnitAbilityLevel(u, 'BHav') == 0 && GetUnitAbilityLevel(u, 'B02Z') == 0) {
                    UnitAddAbility(u, 'A041');
                    IssueImmediateOrder(u, "restorationon");
                    t.deleteLater();
                }
                u = null;
            }).start(1.0).setData(id);
            u = null;
            return false;
        }));
		
		// Polar Fury custom bonuses
        t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'A07I');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            integer id = GetUnitIndex(u);
			AddUnitBonus(u, BONUS_ARMOR, 5);
			AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, 150);
            GameTimer.newPeriodic(function(GameTimer t){
                unit u = GetIndexUnit(t.data());
                if (GetUnitAbilityLevel(u, 'B02Z') == 0) {
					AddUnitBonus(u, BONUS_ARMOR, -5);
					AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, -150);
                    t.deleteLater();
                }
                u = null;
            }).start(1.0).setData(id);
            u = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc