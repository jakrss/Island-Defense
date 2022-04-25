//! zinc

// TDNQ
library DemonicusNukeMinion requires GameTimer, GT, xebasic, xepreload, GenericTitanTargets {
    private struct DemonicusNukeMinion extends GenericTitanNuke {
        module GenericTitanBounceNuke;
        
        method abilityId() -> integer {
            return 'TDNQ';
        }
        
        method targetEffect() -> string {
            return "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl";
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