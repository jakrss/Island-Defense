//! zinc

// TLAE
library VoltronMinionHeal requires GenericTitanTargets {
	private struct VoltronMinionHeal extends GenericTitanHeal {
		module GenericTitanBounceHeal;
		
        method abilityId() -> integer {
            return 'TVNE';
        }
		
		method targetEffect() -> string {
			return "Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl";
		}
		
		method lightningEffect() -> string {
			return "CLSB";
		}
        
        public method onCheckTarget(unit u) -> boolean {
            return !IsUnitInGroup(u, this.bouncedUnits) && IsUnitHealable(u, this.caster);
        }
    }
}


//! endzinc