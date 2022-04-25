//! zinc

library MolteniousHeal requires GenericTitanTargets {
    private struct MolteniousHeal extends GenericTitanHeal {
		module GenericTitanAreaHeal;
        
        method abilityId() -> integer {
            return 'TMAE';
        }
		
		method targetEffect() -> string {
			return "Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosTarget.mdl";
		}
		
		method lightningEffect() -> string {
			return "AFOD";
		}
        
        method onCheckTarget(unit u) -> boolean {
            return IsUnitHealable(u, this.caster);
        }
    }
}

//! endzinc