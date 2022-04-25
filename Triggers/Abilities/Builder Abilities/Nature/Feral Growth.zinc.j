//! zinc
library FeralGrowth {
    private constant integer AutoPassive = 'A0MT';
	private constant integer ArmorBonus = 'A0N8';
	private constant integer Chaos = 'S00O';
	private constant integer GrowthDuration = 6; //(Levels of armor bonus) - Remember to change the ability too!

    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() {
            unit u = GetTriggerUnit();
            integer GrowthStage = GetUnitAbilityLevel(u, ArmorBonus);
			if(GetSpellAbilityId() == AutoPassive) {
				if(GetUnitAbilityLevel(u, ArmorBonus) > 0) {
					if(GetUnitAbilityLevel(u, ArmorBonus) == GrowthDuration) {
						UnitRemoveAbility(u, ArmorBonus);
						UnitAddAbility(u, Chaos);
					} else { IncUnitAbilityLevel(u, ArmorBonus); }
				} else { UnitAddAbility(u, ArmorBonus); }
			}
            u = null;
        });
        t = null;
    }
}
//! endzinc

