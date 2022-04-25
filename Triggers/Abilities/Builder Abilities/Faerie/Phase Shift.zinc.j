//! zinc

library PhaseShift {
    private struct PhaseShift {
        private unit caster = null;
        
        private static method create() -> thistype {
            return 0; // Dummy create, use begin
        }
        
        public static method begin(unit u) -> thistype {
            thistype this = thistype.allocate();
            this.caster = u;
            //SetUnitInvulnerable(u, true);	//Making unit invulnerable overlaps with other stuff.
			UnitAddAbility(u, 'INVU');
            GameTimer.newPeriodic(function(GameTimer t) {
                PhaseShift this = t.data();
                unit u = null;
                if (this == 0) t.deleteLater();
                u = this.caster;
                if (GetUnitAbilityLevel(u, 'Bpsh') == 0) {
                    // No longer has buff, stop invuln
					UnitRemoveAbility(u, 'INVU');
                    //SetUnitInvulnerable(u, false);	//Making unit invulnerable overlaps with other stuff.
                    t.deleteLater();
                }
                u = null;
            }).start(0.25).setData(this);
            
            return this;
        }
    }
    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'A05K');
        TriggerAddCondition(t, Condition(function() -> boolean {
            PhaseShift.begin(GetTriggerUnit());
            return false;
        }));
        t = null;
    }
}

//! endzinc