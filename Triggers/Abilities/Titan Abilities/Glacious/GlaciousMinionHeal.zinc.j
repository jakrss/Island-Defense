//! zinc

// TGNE

library GlaciousMinionHeal requires GenericTitanTargets {
	private struct GlaciousMinionHeal extends GenericTitanHeal {
		module GenericTitanBounceHeal;
		
        method abilityId() -> integer {
            return 'TGNE';
        }
		
		method targetEffect() -> string {
			return "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorTarget.mdl";
		}
		
		method lightningEffect() -> string {
			return "DRAM";
		}
        
        public method onCheckTarget(unit u) -> boolean {
            return !IsUnitInGroup(u, this.bouncedUnits) && IsUnitHealable(u, this.caster);
        }
    }
}


//! endzinc