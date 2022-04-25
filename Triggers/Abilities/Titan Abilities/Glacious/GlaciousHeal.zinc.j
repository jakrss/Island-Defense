//! zinc

library GlaciousHeal requires GenericTitanTargets {
    private struct GlaciousHeal extends GenericTitanHeal {
		module GenericTitanAreaHeal;
        
        method abilityId() -> integer {
            return 'TGAE';
        }
		
		method targetEffect() -> string {
			return "Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl";
		}
		
		method lightningEffect() -> string {
			return "DRAM";
		}
        
        method onCheckTarget(unit u) -> boolean {
            return IsUnitHealable(u, this.caster);
        }
    }
}


//! endzinc