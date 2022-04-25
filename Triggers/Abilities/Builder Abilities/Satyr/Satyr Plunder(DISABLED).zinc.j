//! zinc

library Plunder requires Damage, ShowTagFromUnit {
    function plunder(unit attacker, unit attacked){
        integer level = GetHeroLevel(attacked);
        integer gold = 0;
        integer wood = 0;
        string s = "";
        PlayerData p = PlayerData.get(GetOwningPlayer(attacker));
        
        if (level < 6) gold = 3;
        else if (level <= 9) gold = 4;
        else if (level <= 11) gold = 5;
        else gold = 6;
        
        if (UnitManager.isMinion(attacked)) {
            gold = gold - 1;
        }
        wood = gold * 50;
        
        p.setGold(p.gold() + gold);
        p.setWood(p.wood() + wood);
        
        s = "|cffffd700+" + I2S(gold) + "|r\n\n|ccf01bf4d+" + I2S(wood) + "|r";
        if (GetLocalPlayer() == p.player()) {
            ShowTagFromUnit(s, attacker);
        }
        s = "";
    }
	
	private function checkUnits(unit attacker, unit attacked) -> boolean {
		return !IsUnitIllusion(attacker) && !IsUnitIllusion(attacked) &&
               (UnitManager.isTitan(attacked) || UnitManager.isMinion(attacked));
	}
    
    private function setup() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_ATTACKED );
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit a = GetAttacker();
            unit u = GetTriggerUnit();
            if (GetUnitAbilityLevel(a, 'A0BS') > 1 && checkUnits(a, u)) {
                plunder(a, u);
            }
            a = null;
            u = null;
            return false;
        }));
        t = CreateTrigger();
        Damage_RegisterEvent(t);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit a = GetEventDamageSource();
            unit u = GetTriggerUnit();
            real damage = GetEventDamage();
            // Threshold of 40 so whirlpool etc don't damage
            if (GetUnitAbilityLevel(a, 'A0BS') == 1 && checkUnits(a, u) &&
                Damage_IsAttack() && damage > 40.0) {
                plunder(a, u);
            }
            a = null;
            u = null;
            return false;
        }));
        t = null;
    }

    private function onInit() {
        setup.execute();
    }
}

//! endzinc