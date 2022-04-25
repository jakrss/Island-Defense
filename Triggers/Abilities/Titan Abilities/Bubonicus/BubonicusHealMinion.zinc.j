//! zinc

library BubonicusHealMinion requires GenericTitanTargets {
	private struct BubonicusHealMinion extends GenericTitanHeal {
		module GenericTitanBounceHeal;
		
        method abilityId() -> integer {
            return 'TBNE';
        }
		
		method targetEffect() -> string {
			return "Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl";
		}
		
		method lightningEffect() -> string {
			return "LEAS";
		}
        
        method onCheckTarget(unit u) -> boolean {
            return !IsUnitInGroup(u, this.bouncedUnits) && IsUnitHealable(u, this.caster);
        }
    }
}

//! endzinc