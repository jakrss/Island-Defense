//! zinc

library PirateBarrelOfExplosives requires GT, xedamage {
    private struct PirateBarrelOfExplosives {
        private static constant real farDamageFactor = 0.5;
        private static constant real incendiaryRangeFactor = 1.2;
        private static constant string explosionEffect = "Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl";
        
        private static method onInit(){
            trigger t = CreateTrigger();
            GT_RegisterUnitDiesEvent(t, 'u011');
	    GT_RegisterUnitDiesEvent(t, 'u012');
            TriggerAddCondition(t, Condition(function() -> boolean {
                unit u = GetDyingUnit();
                unit k = GetKillingUnit();
                real x = GetUnitX(u);
                real y = GetUnitY(u);
                real damage = 0.0;
                real radiusNear = 0.0;
                real radiusFar = 0.0;
                integer level = GetUnitAbilityLevel(u, 'A0FZ');
		integer rLevel = GetPlayerTechCount(GetOwningPlayer(u), 'R04L', true);
                xedamage d = 0;
                
		if(rLevel > 0) {
		    //Abilities start at level 1 (if a unit has it) - Research Level + 1 should be the level
		    if(1 + rLevel != level) level = 1 + rLevel;
		}
                if ((k != null && IsUnitEnemy(k, GetOwningPlayer(u)))
                    && level > 0){
                    d = xedamage.create();
                    d.atype = ATTACK_TYPE_MELEE;
                    d.dtype = DAMAGE_TYPE_NORMAL;
                    d.abilityFactor('WARD', 0.5); // 50% Damage to Wards
                    d.useSpecialEffect(thistype.explosionEffect, "origin");
                    d.damageAllies = false;
                    d.damageNeutral = false;
                    d.exception = UNIT_TYPE_FLYING;
                    
                    // Calculate ability level data
                    if (level == 1){
                        damage = 100.0;
                        radiusNear = 300.0;
                        radiusFar = 500.0;
                    }
                    else if (level == 2){
                        damage = 200.0;
                        radiusNear = 300.0;
                        radiusFar = 500.0;
                    }
                    else if (level == 3){
                        damage = 400.0;
                        radiusNear = 300.0;
                        radiusFar = 500.0;
                    }
                    else if (level == 4){
                        damage = 600.0;
                        radiusNear = 300.0;
                        radiusFar = 500.0;
                    }
                    else {
                        damage = 0.0;
                        radiusNear = 0.0;
                        radiusFar = 0.0;
                    }
                    
                    // Apply Incendiary Bonus 
                    if (GetUnitAbilityLevel(k, 'B03D') > 0 ||
                        GetUnitAbilityLevel(k, 'B03C') > 0){ // BO3C (Non-stacking)
                        // Killing unit has Incendiary buff, double damage
                        damage = damage * 2;
                        radiusNear = radiusNear * thistype.incendiaryRangeFactor;
                        radiusFar = radiusFar * thistype.incendiaryRangeFactor;
                    } 
                    
                    d.damageAOE(u, x, y, radiusFar, damage * thistype.farDamageFactor);
                    d.damageAOE(u, x, y, radiusNear, damage - (damage * thistype.farDamageFactor));
                    d.destroy();
                }
                
                u = null;
                k = null;
                return false;
            }));
            t = null;
        }
    }
}

//! endzinc