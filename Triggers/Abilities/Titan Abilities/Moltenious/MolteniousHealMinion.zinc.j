//! zinc

library MolteniousHealMinion requires GenericTitanTargets {
    private struct MolteniousHealMinion extends GenericTitanHeal {
		module GenericTitanBounceHeal;
		
        method abilityId() -> integer {
            return 'TMNE';
        }
		
		method targetEffect() -> string {
			return "Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl";
		}
		
		method lightningEffect() -> string {
			return "AFOD";
		}
        
        method onCheckTarget(unit u) -> boolean {
            return !IsUnitInGroup(u, this.bouncedUnits) && IsUnitHealable(u, this.caster);
        }
    }
}

//! endzinc