//! zinc

// TGNQ
library GlaciousMinionNuke requires GenericTitanTargets {
    private struct GlaciousMinionNuke {
        private static constant integer ABILITY_ID = 'TGNQ';
        private static constant integer EFFECT_ABILITY_ID = 'TGA0';
        private static constant string POSITION_EFFECT = "Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl";
        private static constant string TARGET_EFFECT = "Abilities\\Weapons\\ZigguratFrostMissile\\ZigguratFrostMissile.mdl";
        
        private method setup(integer level){
            this.damage.dtype = DAMAGE_TYPE_MAGIC;
            this.damage.exception = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(thistype.TARGET_EFFECT, "chest");
            
            if (level == 1){
                this.damageAmount = 135.0;
                this.damageArea = 250.0;
            }
            else if (level == 2){
                this.damageAmount = 155.0;
                this.damageArea = 250.0;
            }
            else if (level == 3){
                this.damageAmount = 180.0;
                this.damageArea = 250.0;
            }
        }
        
        public unit caster = null;
        private xecast cast = 0;
        private player castingPlayer = null;
        private integer level = 0;
        
        private real damageAmount = 0.0;
        private real damageArea = 0.0;
        private xedamage damage = 0;
        
        public method checkTarget(unit u) -> boolean {
            return IsUnitNukable(u, this.caster);
        }
        
        private method damageUnitsInArea(real x, real y) {
            unit u = null;
            group g = CreateGroup();
            
            // Create effect
            DestroyEffectTimed(AddSpecialEffect(thistype.POSITION_EFFECT, x, y), 1.0);
            
            GroupEnumUnitsInRange(g, x, y, this.damageArea, null);
            
            u = FirstOfGroup(g);
            while (u != null) {
                if (this.checkTarget(u)) {
                    // Deal damage to units in area matching checkTarget
                
                    if (this.damage.damageTarget(this.caster, u, this.damageAmount)) {
                        // Slow units that are damaged for this.slowDuration
                        this.cast.castOnTarget(u);
                    }
                }
                
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            
            // Finish
            GroupClear(g);
            DestroyGroup(g);
            u = null;
            g = null;
        }
        
        private static method begin(unit caster, real x, real y, integer level) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.castingPlayer = GetOwningPlayer(this.caster);
            this.level = level;
        
            this.damage = xedamage.create();
            this.cast = xecast.createBasic(thistype.EFFECT_ABILITY_ID, OrderId("acidbomb"), this.castingPlayer);
            this.cast.recycledelay = 3.0;
            this.cast.level = this.level;
            this.setup(this.level);
            
            this.damageUnitsInArea(x, y);
            
            this.destroy();
            
            return 0;
        }
        
        
        private method onDestroy(){
            this.cast.destroy();
            this.cast = 0;
            this.damage.destroy();
            this.damage = 0;
            this.caster = null;
            this.castingPlayer = null;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            real x = GetSpellTargetX();
            real y = GetSpellTargetY();
            unit u = GetSpellTargetUnit();
            integer level = GetUnitAbilityLevel(caster, thistype.ABILITY_ID);
            thistype this = 0;
            if (u != null) {
                x = GetUnitX(u);
                y = GetUnitY(u);
            }
            thistype.begin(caster, x, y, level);
            u = null;
            caster = null;
        }
        
        public static method onSetup(){
            trigger t = CreateTrigger();
            GT_RegisterStartsEffectEvent(t, thistype.ABILITY_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            t = null;
            XE_PreloadAbility(thistype.ABILITY_ID);
            XE_PreloadAbility(thistype.EFFECT_ABILITY_ID);
        }
    }
    
    private function onInit(){
        GlaciousMinionNuke.onSetup.execute();
    }
}


//! endzinc