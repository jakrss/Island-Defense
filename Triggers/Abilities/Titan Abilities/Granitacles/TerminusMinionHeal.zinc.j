//! zinc

library TerminusMinionHeal requires GenericTitanTargets {
    private struct TerminusMinionHeal extends GenericTitanHeal {
		module GenericTitanAreaHeal;
        
        method abilityId() -> integer {
            return 'TTNE';
        }
		
		method onSetup(integer level){
            if (level == 1){
                this.healAmount = 300.0;
            }
            else if (level == 2){
                this.healAmount = 400.0;
            }
            else if (level == 3){
                this.healAmount = 500.0;
            }
            else if (level == 4){
                this.healAmount = 600.0;
            }
			this.healRange = 400.0;
        }
		
		method targetEffect() -> string {
			return "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl";
		}
        
        public method onCheckTarget(unit u) -> boolean {
            return IsUnitHealable(u, this.caster);
        }
    }
}

//! endzinc