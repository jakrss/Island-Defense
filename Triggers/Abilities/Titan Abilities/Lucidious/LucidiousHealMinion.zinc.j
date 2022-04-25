//! zinc

library LucidiousHealMinion requires GenericTitanTargets {
    private struct LucidiousHealMinion extends GenericTitanHeal {
		module GenericTitanBounceHeal;
		
        method abilityId() -> integer {
            return 'TLNE';
        }
		
		method targetEffect() -> string {
			return "Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveDamage.mdl";
		}
		
		method lightningEffect() -> string {
			return "DRAM";
		}
        
        method onCheckTarget(unit u) -> boolean {
            return !IsUnitInGroup(u, this.bouncedUnits) && IsUnitHealable(u, this.caster);
        }
    }
}

//! endzinc