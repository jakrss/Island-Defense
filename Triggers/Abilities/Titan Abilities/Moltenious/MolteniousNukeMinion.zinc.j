//! zinc

library MolteniousNukeMinion requires GenericTitanTargets {
    private struct MolteniousNukeMinion extends GenericTitanNuke {
        module GenericTitanBounceNuke;
        
        method abilityId() -> integer {
            return 'TMNQ';
        }
        
        method targetEffect() -> string {
            return "Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl";
        }
        
        public method onCheckTarget(unit u) -> boolean {
            return !IsUnitInGroup(u, this.bouncedUnits) && IsUnitNukable(u, this.caster) && IsUnitVisible(u, this.castingPlayer);
        }
    }
}

//! endzinc