//! zinc
library Voltron requires GT, xebasic, xepreload, BonusMod, GameTimer {
	private constant integer DISCHARGE_ID = 'A0NH';
	private constant integer DUMMY = 'e01B';
	private constant integer ORDER_ID = 852066;

    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterLearnsAbilityEvent(t, 'TVAW');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetLearningUnit();
            integer l = GetHeroLevel(u);
            UnitAddAbility(u, 'TVA0');
            SetUnitAbilityLevel(u, 'TVA0', IMinBJ(R2I(l / 2.0), 6));
            u = null;
            return false;
        }));
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function() -> boolean {
            unit u = GetLevelingUnit();
            integer l = GetHeroLevel(u);
            if (GetUnitAbilityLevel(u, 'TVA0') > 0) {
                SetUnitAbilityLevel(u, 'TVA0', IMinBJ(R2I(l / 2.0), 6));
            }
            
            if (GetUnitAbilityLevel(u, 'TVAD') > 0) {
                SetUnitAbilityLevel(u, 'TVAD', IMinBJ(R2I(l / 2.0), 6));
            }
            u = null;
            return false;
        });
        
        GT_AddStartsEffectAction(function() -> boolean {
            unit u = GetTriggerUnit();
            integer id = GetUnitIndex(u);
			real XLoc = GetUnitX(u);
			real YLoc = GetUnitY(u);
			unit xeUnit;
            UnitAddAbility(u, 'TVA1'); // Bonus Attack Speed
			xeUnit = CreateUnit(GetOwningPlayer(u), DUMMY, XLoc, YLoc, 0);
				UnitAddAbility(xeUnit, DISCHARGE_ID);
				SetUnitAbilityLevel(xeUnit, DISCHARGE_ID, 7);
                IssueTargetOrderById(xeUnit, ORDER_ID, u);
            GameTimer.new(function(GameTimer t) {
                unit u = GetIndexUnit(t.data());
                UnitRemoveAbility(u, 'TVA1');
                UnitRemoveAbility(u, 'B034'); // Remove buff too
                u = null;
            }).start(5.0).setData(id);
            u = null;
            return false;
        }, 'TVAF');
        
        // Tome of Retraining check
        t = CreateTrigger();
        GT_RegisterItemUsedEvent(t, 'I05S');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            UnitRemoveAbility(u, 'TVA0');
            u = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc