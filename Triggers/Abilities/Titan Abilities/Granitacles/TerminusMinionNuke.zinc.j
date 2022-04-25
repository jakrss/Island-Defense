//! zinc

library TerminusMinionNuke requires GenericTitanTargets {
    private struct TerminusMinionNukeWave extends xecollider {
        private TerminusMinionNuke object = 0;
        public method setNukeObject(TerminusMinionNuke object){
            this.object = object;
        }
        
        public method onUnitHit(unit hitTarget){
            this.object.onUnitHit.execute(hitTarget);
        }
		
		public method loopControl(){
            real dx = (this.homingTargetX - this.x);
            real dy = (this.homingTargetY - this.y);
            real range = SquareRoot(dx * dx + dy * dy);

            if (range < 50.0){
                this.object.destroy();
                this.terminate();
            }
        }
    }
    private struct TerminusMinionNuke {
        private static constant integer ABILITY_ID = 'TTNQ';
        private static constant string WAVE_EFFECT = "Doodads\\LordaeronSummer\\Terrain\\LoardaeronRockChunks\\LoardaeronRockChunks3.mdl";
        private static constant string TARGET_EFFECT = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl";

        private method setup(integer level){
            this.damage.dtype = DAMAGE_TYPE_MAGIC;
            this.damage.exception = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(thistype.TARGET_EFFECT, "origin");
            this.damage.forceEffect = true;
            
            if (level == 1){
                this.damageAmount = 130.0;
                this.distance = 600.0; // +50 due to loopControl constraints
            }
            else if (level == 2){
                this.damageAmount = 155.0;
                this.distance = 600.0; // +50 due to loopControl constraints
            }
            else if (level == 3){
                this.damageAmount = 180.0;
                this.distance = 600.0; // +50 due to loopControl constraints
            }
            
            this.wave.fxpath = thistype.WAVE_EFFECT;
			this.wave.collisionSize = 150.0;
            this.wave.speed = 1100; // How far it travels in 1 second.
        }
        
        private unit caster = null;
        private player castingPlayer = null;
        private integer level = 0;
        private real distance = 0.0;
        private real damageAmount = 0.0;
        private xedamage damage = 0;
        private TerminusMinionNukeWave wave = 0;
        
        public method checkTarget(unit u) -> boolean {
            return !IsUnit(u, this.caster) && IsUnitNukable(u, this.caster);
        }
        
        public method onUnitHit(unit u){
            if (!this.checkTarget(u)) return;
            this.damage.damageTarget(this.caster, u, this.damageAmount);
        }
        
        private static method begin(unit caster, real x, real y, integer level) -> thistype {
            thistype this = thistype.allocate();
            real castX = GetUnitX(caster);
            real castY = GetUnitY(caster);
            real angle = Atan2(y - castY, x - castX);
            real endX = 0.0;
            real endY = 0.0;
            
            this.level = level; // Sigh
            
            this.caster = caster;
            this.castingPlayer = GetOwningPlayer(this.caster);
            
            this.damage = xedamage.create();
            
            this.wave = TerminusMinionNukeWave.create(castX, castY, angle);
            this.wave.setNukeObject(this);
            this.wave.owner = this.castingPlayer;
            
            this.setup(this.level);
            endX = castX + this.distance * Cos(angle);
            endY = castY + this.distance * Sin(angle);
            
            this.wave.setTargetPoint(endX, endY);
            
            return this;
        }
        
        private method onDestroy(){
            this.damage.destroy();
            this.caster = null;
            this.castingPlayer = null;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            integer level = GetUnitAbilityLevel(caster, thistype.ABILITY_ID);
            real x = GetSpellTargetX();
            real y = GetSpellTargetY();
            TerminusMinionNuke.begin(caster, x, y, level);
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
        TerminusMinionNuke.onSetup.execute();
    }
}

//! endzinc