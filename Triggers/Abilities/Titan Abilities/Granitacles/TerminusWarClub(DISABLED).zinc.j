//! zinc

library TerminusWarClub requires GT, xebasic, xepreload, BonusMod, GameTimer{
    private struct TerminusWarClub {
		destructable d = null;
		unit u = null;
		GameTimer t = 0;
	
        public static method onAbilitySetup(){
            trigger t = CreateTrigger();
			GT_RegisterStartsEffectEvent(t, 'TTA1');
			TriggerAddCondition(t, Condition(function() -> boolean {
				unit u = GetSpellAbilityUnit();
				destructable d = GetSpellTargetDestructable();
				thistype this = thistype.allocate();
				this.d = d;
				
				debug {BJDebugMsg("Detected " + GetUnitName(u) + " using War Club on " + GetDestructableName(d));}
				this.u = u;
				this.t = GameTimer.newPeriodic(function(GameTimer t) {
					thistype this = t.data();
					if (this != 0) {
						if (UnitAlive(this.u) && GetUnitAbilityLevel(this.u, 'Bgra') > 0) {
							debug {BJDebugMsg("Still has club!");}
						}
						else {
							debug {BJDebugMsg("No club, destroying instance...");}
							this.u = null;
							t.deleteNow();
							this.t = 0;
							this.destroy();
						}
					}
				});
				this.t.setData(this);
				this.t.start(0.5);
				
				// Restore Tree to Life
				GameTimer.new(function(GameTimer t) {
					thistype this = t.data();
					if (this != 0) {
						DestructableRestoreLife(this.d, GetDestructableMaxLife(this.d), false);
					}
					this.d = null;
				}).start(0.0).setData(this);
				
				d = null;
				u = null;
				return false;
			}));
			t = null;
        }
	}
    
    private function onInit(){
        TerminusWarClub.onAbilitySetup.execute();
    }
}

//! endzinc