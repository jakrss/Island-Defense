//! zinc

// TBNQ
library BreezeriousNukeMinion requires GameTimer, GT, xebasic, xepreload, GenericTitanTargets {
    private struct BreezeriousNukeMinion extends GenericTitanNuke {
        module GenericTitanBounceNuke;
        
        method abilityId() -> integer {
            return 'A0D5';
        }
        
        method targetEffect() -> string {
            return "Model_AbilityTarget_BreezeriousMinion.mdx";
        }
        
        method onSetup(integer level) {
            // Defaults
        }
        
        public method onCheckTarget(unit u) -> boolean {
            return !IsUnitInGroup(u, this.bouncedUnits) && IsUnitNukable(u, this.caster) && IsUnitVisible(u, this.castingPlayer);
        }
    }
}


//! endzinc