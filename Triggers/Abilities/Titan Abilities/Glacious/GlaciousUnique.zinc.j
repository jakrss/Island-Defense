//! zinc

// TSAF
library GlaciousUnique requires GenericTitanTargets {
    private struct GlaciousUnique {
        private static constant integer ABILITY_ID = 'TGAR';
        private static constant integer EFFECT_ABILITY_ID = 'S002';
        
        private unit caster = null;
        private player castingPlayer = null;
        
        private static method begin(unit caster, real x, real y) -> thistype {
            thistype this = thistype.allocate();
            unit u = null;
            this.caster = caster;
            this.castingPlayer = GetOwningPlayer(this.caster);
            u = XE_NewDummyUnit(this.castingPlayer, x, y, 270.0);
            GroupAddUnit(glacLocustGroup, u);
            UnitAddAbility(u, thistype.EFFECT_ABILITY_ID);
            SetUnitAbilityLevel(u, thistype.EFFECT_ABILITY_ID, GetUnitAbilityLevel(this.caster, thistype.ABILITY_ID));
            UnitApplyTimedLife(u, 'BTLF', 20.0);
            u = null;
            
            this.destroy();
            
            return this;
        }
        
        private method onDestroy(){
            this.caster = null;
            this.castingPlayer = null;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            real x = GetSpellTargetX();
            real y = GetSpellTargetY();
            thistype.begin(caster, x, y);
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
        GlaciousUnique.onSetup.execute();
    }
}


//! endzinc