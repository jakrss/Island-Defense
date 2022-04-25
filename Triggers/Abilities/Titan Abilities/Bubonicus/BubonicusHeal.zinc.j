//! zinc

// TBAE
library BubonicusHeal requires GT, xebasic, xepreload, LightningUtils, GenericTitanTargets, Healing {
    private struct BubonicusHeal {
        private static constant integer ABILITY_ID = 'TBAE';
        private static constant string TARGET_EFFECT = "Objects\\Spawnmodels\\Orc\\Orcblood\\OrdBloodWyvernRider.mdl";
        private static constant real DAMAGE_FACTOR = 1.33;
        
		private boolean useLightning = true;
        private method setup(integer level){
            this.damage.dtype = DAMAGE_TYPE_UNIVERSAL;
            this.damage.exception = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(thistype.TARGET_EFFECT, "chest");
            this.damage.forceEffect = true;
            
            if (level == 1){
                this.healAmount = 200.0;
                this.healRange = 500.0;
            }
            else if (level == 2){
                this.healAmount = 400.0;
                this.healRange = 600.0;
            }
            else if (level == 3){
                this.healAmount = 600.0;
                this.healRange = 600.0;
            }
            else if (level == 4){
                this.healAmount = 800.0;
                this.healRange = 700.0;
            }
			
			if (!GameSettings.getBool("LIGHTNING_EFFECTS_ENABLED")) {
				this.useLightning = false;
			}
        }
        private unit caster = null;
        private player castingPlayer = null;
        private integer level = 0;
        private boolean hasBonus = false;
        private real healAmount = 0.0;
        private real healRange = 0.0;
        private xedamage damage = 0;
        private xecast cast = 0;
        
        public method checkTarget(unit u) -> boolean {
            return !IsUnit(u, this.caster) && IsUnitHealable(u, this.caster);
        }
        
        private method healArea(){
            group g = CreateGroup();
            unit u = null;
            lightning l = null;
            
            GroupEnumUnitsInRange(g, GetUnitX(this.caster), GetUnitY(this.caster), this.healRange, null);
            
            u = FirstOfGroup(g);
            while (u != null){
                if (this.checkTarget(u)){
                    this.damage.damageTarget(this.caster, u, this.healAmount * thistype.DAMAGE_FACTOR);
                    if (this.hasBonus) {
                        // Cast a buff here!
                        this.cast.castOnTarget(u);
                    }
					
					
					if (this.useLightning) {
						l = CreateLightningBetweenUnits("AFOD", true, this.caster, u);
						SetLightningFadeTime(l, 1.0);
						ReleaseLightning(l);
					}
                }
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            
            GroupClear(g);
            DestroyGroup(g);
            g = null;
            u = null;
            l = null;
        }
        
        private static method begin(unit caster, integer level) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.level = level;
            this.castingPlayer = GetOwningPlayer(this.caster);
            
            this.damage = xedamage.create();
            this.damage.damageSelf = true;
            this.damage.damageAllies = true;
            this.damage.damageEnemies = false;
            this.damage.damageNeutral = false;
            this.damage.allyfactor = -1.0;
            this.healAmount = this.healAmount + getInsightBonus(this.caster);
            this.cast = xecast.createBasic('A040', OrderId("bloodlust"), this.castingPlayer);
            
            this.setup(this.level);
            
            if (Bubonicus[this.caster].count() > 0) {
                // Consumes a corpse
                this.hasBonus = true;
                Bubonicus[this.caster].subtract();
                
                this.damage.damageTarget(this.caster, this.caster, this.healAmount * thistype.DAMAGE_FACTOR);
                this.cast.castOnTarget(this.caster);
            }
            else if (RAbsBJ(this.damage.getTargetFactor(this.caster, this.caster) * this.healAmount * thistype.DAMAGE_FACTOR) <
                    GetUnitState(this.caster, UNIT_STATE_LIFE)) {
                // Deals damage to yourself
                this.damage.allyfactor = 1.0;
                this.damage.damageTarget(this.caster, this.caster, this.healAmount * thistype.DAMAGE_FACTOR);
                this.damage.allyfactor = -1.0;
            }
            else {
                return this;
            }
            
            // Since 4.0.0.0099, grant bonus to Minions even if you don't consume a corpse.
            this.hasBonus = true;
            
            this.healArea();
            
            GameTimer.new(function(GameTimer t) {
                thistype this = t.data();
                this.destroy();
            }).start(1.00).setData(this);
            
            return this;
        }
        
        private method onDestroy(){
            this.cast.destroy();
            this.damage.destroy();
            this.caster = null;
            this.castingPlayer = null;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            integer level = GetUnitAbilityLevel(caster, thistype.ABILITY_ID);
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
        BubonicusHeal.onSetup.execute();
    }
}


//! endzinc