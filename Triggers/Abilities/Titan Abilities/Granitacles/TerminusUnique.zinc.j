//! zinc

library TerminusUnique requires GT, xebasic, xepreload, BonusMod {
    private struct TerminusUnique {
        public static method onAbilitySetup(){
            trigger t = CreateTrigger();
			GT_RegisterLearnsAbilityEvent(t, 'TTAR');
			TriggerAddCondition(t, Condition(function() -> boolean {
				unit u = GetLearningUnit();
				integer i = GetLearnedSkillLevel();
				
				IncUnitAbilityLevel(u, 'TTA0'); // Boost Pebble Toss
				AddUnitBonus(u, BONUS_STRENGTH, 6*i);
				
				u = null;
				return false;
			}));
			// Tome of Retraining check
			t = CreateTrigger();
			GT_RegisterItemUsedEvent(t, 'I05S');
			TriggerAddCondition(t, Condition(function() -> boolean {
				unit u = GetTriggerUnit();
				integer wasLevel = GetUnitAbilityLevel(u, 'TTA0') - 1;
				
				// Total Bonus is 18
				if (wasLevel >= 1) AddUnitBonus(u, BONUS_STRENGTH, -6);
				if (wasLevel == 2) AddUnitBonus(u, BONUS_STRENGTH, -12);
				
				SetUnitAbilityLevel(u, 'TTA0', 1);
				
				u = null;
				return false;
			}));
			t = null;
        }
	}
    
    private function onInit(){
        TerminusUnique.onAbilitySetup.execute();
    }
}

//! endzinc