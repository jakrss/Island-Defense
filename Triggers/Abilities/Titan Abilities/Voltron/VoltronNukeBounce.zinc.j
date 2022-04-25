//! zinc

library VoltronNuke requires GenericTitanTargets {
    private struct VoltronNuke extends GenericTitanNuke {
        module GenericTitanBounceNuke;
        
        method abilityId() -> integer {
            return 'TVAQ';
        }
        
        method targetEffect() -> string {
            return "war3mapImported\\LightningSphere_FX.mdx";
        }
        
        method missileEffect() -> string {
            return "war3mapImported\\OrbOfLightning.mdx";
        }
        
        public method onCheckTarget(unit u) -> boolean {
            return !IsUnitInGroup(u, this.bouncedUnits) && IsUnitNukable(u, this.caster) && IsUnitVisible(u, this.castingPlayer) && this.bounceCount < this.bounceCountMax;
        }
        
        public method onSetup(integer level) {
            this.bounceRange = 220.0;
            this.bounceTimerDelay = 0.10;
            this.bounceCountMax = 3+(level*3);
            this.damage.useSpecialEffect(this.targetEffect(), "head");
            this.useMissiles = true;
        }
    }
}


//! endzinc