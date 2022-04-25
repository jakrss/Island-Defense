//! zinc

library SpikedStructures {
    private constant integer ABILITY_ID = 'A065';
    private constant boolean PERCENTAGE_RETURN = true; //Whether the attackers melee damage matters at all
    private constant integer DAMAGE_PER_LEVEL = 10; //Non-percentage based - will do 10 damage back for each attack per level of the spiked structures ability
    private constant real DAMAGE_PER_LEVEL_PERCENT = .075; //7.5% per level, level 1 returns 2.5%, level 2 returns 5%
    
    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t , Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            unit a = GetEventDamageSource();
            real damageAmount = GetEventDamage();
	    player p = GetOwningPlayer(u);
	    integer level = GetUnitAbilityLevel(u, ABILITY_ID);
	    real damage;
            if (level > 0 && IsUnitEnemy(a, p) && BlzGetEventAttackType() == ATTACK_TYPE_NORMAL && damageAmount > 10) {
		// Has Spiked
		if(PERCENTAGE_RETURN) {
		    damage = damageAmount * (DAMAGE_PER_LEVEL_PERCENT * level);
		} else {
		    damage = level * DAMAGE_PER_LEVEL;
		}
		UnitDamageTarget(u, a, damage, false, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, WEAPON_TYPE_WHOKNOWS);
            }
            a = null;
            u = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc