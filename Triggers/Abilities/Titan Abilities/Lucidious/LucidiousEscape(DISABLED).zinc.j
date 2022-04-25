//! zinc

// TLAW
library LucidiousEscape requires GameTimer, GT, xepreload {
    private struct LucidiousEscape {
        private static constant integer ABILITY_ID = 'TLAW';
        
        private method setup(integer level){
        }
        private unit caster = null;
        private integer level = 0;
        private GameTimer buffTimer = 0;
        
        private static method begin(unit caster, integer level) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.level = level;
            BJDebugMsg("begin");
            // Add buffs
            // Disables autoattack
            UnitAddType(this.caster, UNIT_TYPE_PEON);
            // + Perma Invis
            UnitAddAbility(this.caster, 'A034');
            
            this.buffTimer = GameTimer.new(function(GameTimer t) {
                thistype this = t.data();
                
                BJDebugMsg("tick");
                if (this != 0) {
                    t.deleteLater();
                    this.destroy();
                }
            });
            this.buffTimer.setData(this);
            this.buffTimer.start(10.0);
            
            return this;
        }
        
        private method onDestroy(){
            // Clear buffs
            UnitRemoveAbility(this.caster, 'A034');
            UnitRemoveType(this.caster, UNIT_TYPE_PEON);
            this.caster = null;
            BJDebugMsg("destroy");
            
            if (!this.buffTimer.isDeleting()) {
                this.buffTimer.deleteNow();
                this.buffTimer = 0;
            }
        }
        
        private static method onCast(){
            unit caster = GetTriggerUnit();
            integer level = GetUnitAbilityLevel(caster, thistype.ABILITY_ID);
            BJDebugMsg("cast");
            
            // Remove WW
            UnitRemoveAbility(caster, 'B006');
            thistype.begin(caster, level);
        }
        
        public static method onSetup(){
            trigger t = CreateTrigger();
            GT_RegisterStartsEffectEvent(t, thistype.ABILITY_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            XE_PreloadAbility(thistype.ABILITY_ID);
        }
    }
    
    private function onInit(){
        LucidiousEscape.onSetup();
    }
}


//! endzinc