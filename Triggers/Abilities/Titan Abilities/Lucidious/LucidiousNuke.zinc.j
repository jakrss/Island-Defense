//! zinc

// TLAQ
library LucidiousNuke requires GenericTitanTargets {
    private struct LucidiousNuke extends GenericTitanNuke {
        module GenericTitanBounceNuke;
        
        method abilityId() -> integer {
            return 'TLAQ';
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