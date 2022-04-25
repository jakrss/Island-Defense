//! zinc

// TLAE
library BreezeriousHealMinion requires GenericTitanTargets {
	private struct BreezeriousHealMinion extends GenericTitanHeal {
        module GenericTitanBounceHeal;
        
        method abilityId() -> integer {
            return 'A0D6';
        }
        
        method targetEffect() -> string {
            return "Model_Ability_Minion_Breezerious_Heal.mdx";
        }
        
        method onSetup(integer level) {
            this.bounceRange = 600.0;
            this.bounceTimerDelay = 0.12;
            
            if (level == 1){
                this.damageAmount = 300.0;
                this.bounceCountMax = 1;
            }
            else if (level == 2){
                this.damageAmount = 400.0;
                this.bounceCountMax = 2;
            }
            else if (level == 3){
                this.damageAmount = 500.0;
                this.bounceCountMax = 2;
            }
            else if (level == 4){
                this.damageAmount = 600.0;
                this.bounceCountMax = 3;
            }
        }
        
        public method onCheckTarget(unit u) -> boolean {
            return !IsUnitInGroup(u, this.bouncedUnits) && IsUnitHealable(u, this.caster);
        }
    }
}


//! endzinc