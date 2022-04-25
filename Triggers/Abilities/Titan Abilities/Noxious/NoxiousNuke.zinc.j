//! zinc

library NoxiousNuke requires GameTimer, GT, xebasic, xepreload, xecollider, GenericTitanTargets, IsUnitTitanHunter, ItemExtras, Nukes {
    private struct NoxiousNukeWave extends xecollider {
        private NoxiousNuke object = 0;
        public method setNukeObject(NoxiousNuke object){
            this.object = object;
        }
        
        public method onUnitHit(unit hitTarget){
            this.object.onUnitHit.execute(hitTarget);
        }
        
        private real endSize = 0.0;
        public method setEndSize(real end){
            this.endSize = end;
        }
        
        private real startX = 0.0;
        private real startY = 0.0;
        public method setStartPoint(real x, real y){
            this.startX = x;
            this.startY = y;
        }
        
        // Every 0.025s, recalculate collisionSize
        public method loopControl(){
            real dx = (this.homingTargetX - this.startX);
            real dy = (this.homingTargetY - this.startY);
            real range = SquareRoot(dx * dx + dy * dy);
            real currRange = 0.0;
            real factor = 0.0;
            
            dx = (this.x - this.startX);
            dy = (this.y - this.startY);
            currRange = SquareRoot(dx * dx + dy * dy);
            factor = (currRange / range);
            
            if (factor >= 1.0){
                this.object.destroy();
                this.terminate();
            }
            
            this.collisionSize = factor * this.endSize;
            this.scale = (((factor / 2.0) + 0.5) * (this.endSize / 140.0));
        }
    }
    private struct NoxiousNuke {
        private static constant integer ABILITY_ID = 'TSAQ';
        private static constant string WAVE_EFFECT = "war3mapImported\\NoxiousPoisonMissile.mdx";
        private static constant string TARGET_EFFECT = "war3mapImported\\NoxiousPoisonMissile.mdx";

        private method setup(integer level){
            this.damage.dtype = DAMAGE_TYPE_MAGIC;
            this.damage.exception = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(thistype.TARGET_EFFECT, "origin");
            this.damage.forceEffect = true;
            
            if (level == 1){
                this.damageAmount = 130.0;
                this.distance = 600.0;
            }
            else if (level == 2){
                this.damageAmount = 150.0;
                this.distance = 700.0;
            }
            else if (level == 3){
                this.damageAmount = 180.0;
                this.distance = 800.0;
            }
            
            this.wave.fxpath = thistype.WAVE_EFFECT;
            this.wave.setEndSize(240.0);
        }
        
        private unit caster = null;
        private player castingPlayer = null;
        private integer level = 0;
        private real distance = 0.0;
        private real damageAmount = 0.0;
        private xedamage damage = 0;
        private NoxiousNukeWave wave = 0;
        
        public method checkTarget(unit u) -> boolean {
            return !IsUnit(u, this.caster) && IsUnitNukable(u, this.caster);
        }
        
        public method onUnitHit(unit u){
            if (this.checkTarget(u)) {
                this.damageAmount = this.damageAmount * getModifiers(this.caster, u);
                this.damage.damageTarget(this.caster, u, this.damageAmount);
            }
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
            
            this.wave = NoxiousNukeWave.create(castX, castY, angle);
            this.wave.setNukeObject(this);
            this.wave.owner = this.castingPlayer;
            
            this.setup(this.level);
            
            endX = castX + this.distance * Cos(angle);
            endY = castY + this.distance * Sin(angle);
            
            this.wave.setTargetPoint(endX, endY);
            this.wave.setStartPoint(castX, castY);
            this.wave.scale = 0;
            this.wave.speed = (this.distance / 0.45); // How far it travels in 1 second.
            
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
            NoxiousNuke.begin(caster, x, y, level);
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
        NoxiousNuke.onSetup.execute();
    }
}

//! endzinc