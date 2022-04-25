
//! zinc

library RemoveRallyUpgrades {
    public struct RemoveRally {
        public static method onInit() {
            trigger t = CreateTrigger();
			TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH);
			TriggerAddCondition(t, Condition(function() -> boolean {
				unit u = GetConstructedStructure();
				if (GetUnitAbilityLevel(u, 'ARax') > 0) {
					UnitRemoveAbility(u, 'ARal');
				}
				u = null;
				return false;
			}));
			t = null;
        }
    }
}

//! endzinc