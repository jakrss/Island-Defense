//! zinc

// TBNQ - Exact copy of TLNQ
library BubonicusNukeMinion requires GameTimer, GT, xebasic, xepreload, GenericTitanTargets {
    private struct BubonicusNukeMinion extends GenericTitanNuke {
        module GenericTitanBounceNuke;
        
        method abilityId() -> integer {
            return 'TBNQ';
        }
        
        method targetEffect() -> string {
            return "Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl";
        }
        
        public method onCheckTarget(unit u) -> boolean {
            return !IsUnitInGroup(u, this.bouncedUnits) && IsUnitNukable(u, this.caster) && IsUnitVisible(u, this.castingPlayer);
        }
    }
}


//! endzinc