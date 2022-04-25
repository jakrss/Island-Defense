//! zinc

library SypheriousHealMinion requires GenericTitanTargets {
    private struct SypheriousHealMinion extends GenericTitanHeal {
        module GenericTitanBounceHeal;
        
        method abilityId() -> integer {
            return 'TSNE';
        }
        
        public method onCheckTarget(unit u) -> boolean {
            return !IsUnitInGroup(u, this.bouncedUnits) && IsUnitHealable(u, this.caster);
        }
    }
}

//! endzinc