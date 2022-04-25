//! zinc

// TLNQ
library LucidiousNukeMinion requires GenericTitanTargets {
    private struct LucidiousNukeMinion extends GenericTitanNuke {
        module GenericTitanBounceNuke;
        
        method abilityId() -> integer {
            return 'TLNQ';
        }
        
        method targetEffect() -> string {
            return "Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl";
        }
        
        public method onCheckTarget(unit u) -> boolean {
            return !IsUnitInGroup(u, this.bouncedUnits) && IsUnitNukable(u, this.caster) && IsUnitVisible(u, this.castingPlayer);
        }
    }
}


//! endzinc