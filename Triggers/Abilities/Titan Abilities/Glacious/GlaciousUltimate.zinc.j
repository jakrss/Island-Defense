//! zinc

// TGAF
library GlaciousUltimate requires GenericTitanTargets {
    private struct GlaciousUltimate {
        private static constant integer ABILITY_ID = 'TGAF';
        private static constant integer EFFECT_ABILITY_ID = 'TGA1';
        
        private unit caster = null;
        private player castingPlayer = null;
        private xecast cast = 0;
        
        private static method begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.castingPlayer = GetOwningPlayer(this.caster);
            this.cast = xecast.createBasicA(thistype.EFFECT_ABILITY_ID, OrderId("innerfire"), this.castingPlayer);
            this.cast.recycledelay = 3.0;
            this.cast.castOnTarget(caster);
            
            this.destroy();
            return 0;
        }
        
        private method onDestroy(){
            this.cast = 0;
            this.caster = null;
            this.castingPlayer = null;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            thistype.begin(caster);
        }
        
        public static method onSetup(){
            trigger t = CreateTrigger();
            GT_RegisterStartsEffectEvent(t, thistype.ABILITY_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            XE_PreloadAbility(thistype.ABILITY_ID);
            XE_PreloadAbility(thistype.EFFECT_ABILITY_ID);
        }
    }
    
    private function onInit(){
        GlaciousUltimate.onSetup.execute();
    }
}


//! endzinc