//! zinc

library SypheriousNukeMinion requires GenericTitanTargets {
    private struct SypheriousNukeMinion extends GenericTitanNuke {
        module GenericTitanBounceNuke;
        
        method abilityId() -> integer {
            return 'TSNQ';
        }
        
        method targetEffect() -> string {
            return "war3mapImported\\Model_Nuke(MNAQ)TargetSplash.mdx";
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