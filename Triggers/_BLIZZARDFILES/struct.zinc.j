//! zinc
library StructName requires GT, BUM, ABMA {
    private struct StructName {
        public static hashtable hCocMin = null;
		
		method abilityId() -> integer {
            return thistype.ABILITY_ID;
        }
		
		method targetEffect() -> string {
			return "";
		}

		public method getCaster() -> unit {
			return this.caster;
		}

        private method setup(){
            //setup variables here
        }
        
        private static method begin(unit caster) -> thistype {
            thistype this = thistype.allocate();

            this.caster = caster;
            this.setup();

            return this;
        }
		  
        private method onDestroy(){
            //destroy, cleanup
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            thistype.begin(caster);
        }
        
        public static method onAbilitySetup(){
            trigger t = CreateTrigger();
            GT_RegisterStartsEffectEvent(t, thistype.ABILITY_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            XE_PreloadAbility(thistype.ABILITY_ID);
			t = null;
        }
	}
    
    private function onInit(){
        StructName.onAbilitySetup.execute();
    }
}

//! endzinc