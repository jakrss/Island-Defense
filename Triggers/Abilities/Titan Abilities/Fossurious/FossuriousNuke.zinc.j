//! zinc

library FossuriousNuke requires GenericTitanTargets, UnitStatus {
    private struct FossuriousNukeWave extends xecollider {
        private FossuriousNuke object = 0;
        public method setNukeObject(FossuriousNuke object){
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
            if (range > this.object.distance){ //if nuke has travelled further than defined distance, destroy. There was some weird circumstances where the nuke would never never reach the target and would leak the object
                this.object.destroy();
                this.terminate();
            }
        }
    }

    private struct FossuriousNuke {
        private static constant integer ABILITY_ID = 'A0PW';
        private static constant string WAVE_EFFECT = "Abilities\\Spells\\Undead\\Impale\\ImpaleMissTarget.mdl";
        private static constant string TARGET_EFFECT = "Abilities\\Spells\\Undead\\Impale\\ImpaleHitTarget.mdl";
        private static constant string POSITION_EFFECT = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl";


        private method setup(integer level){
            this.damage.dtype = DAMAGE_TYPE_MAGIC;
            this.damage.exception = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(thistype.TARGET_EFFECT, "origin");
            this.damage.forceEffect = true;
            
            if (level == 1){
                this.damageAmount = 130.0;
                this.damageArea = 500.0;
                this.stunDuration = 0.5;
                this.distance = 600.0; // +50 due to loopControl constraints
            }
            else if (level == 2){
                this.damageAmount = 155.0;
                this.damageArea = 500.0;
                this.stunDuration = 0.5;
                this.distance = 600.0; // +50 due to loopControl constraints
            }
            else if (level == 3){
                this.damageAmount = 180.0;
                this.damageArea = 500.0;
                this.stunDuration = 0.5;
                this.distance = 600.0; // +50 due to loopControl constraints
            }
            
            this.wave.fxpath = thistype.WAVE_EFFECT;
			this.wave.collisionSize = 150.0;
            this.wave.speed = 1100; // How far it travels in 1 second.
        }
        
        private unit caster = null;
        private player castingPlayer = null;
        private integer level = 0;
        public real distance = 0.0;
        private real damageAmount = 0.0;
        private real damageArea = 0.0;
        private real stunDuration = 0.0;
        private boolean hitStructure = false;
        private hashtable hNuke = InitHashtable();
        private xedamage damage = 0;
        private FossuriousNukeWave wave = 0;
        
        public method checkTarget(unit u) -> boolean {
            return !IsUnit(u, this.caster) && IsUnitNukable(u, this.caster);
        }

        public method checkStructure(unit u) -> boolean {
            return IsUnitNukableStructure(u, this.caster);
        }

        private method SpasmicShockStructure(unit u) {
            real x = GetUnitX(u);
            real y = GetUnitY(u);
            unit ue = null;
            group g = CreateGroup();

            // Create effect
            DestroyEffectTimed(AddSpecialEffect(thistype.POSITION_EFFECT, x, y), 1.0);
            this.wave.setTargetPoint(x, y);

            GroupEnumUnitsInRange(g, x, y, this.damageArea, null);
            ue = FirstOfGroup(g);
            while (ue != null) {
                if (this.checkTarget(ue)) {
                    StunUnitTimed(ue, this.stunDuration);
                    //if ue has not been hit already, do some damage..
                    if (!(LoadBoolean(this.hNuke, GetHandleId(ue), 0))) {
                        this.damage.damageTarget(this.caster, ue, this.damageAmount); // damage unit if not already hit by wave
                        SaveBoolean(this.hNuke, GetHandleId(ue), 0, true);
                    }
                }
                GroupRemoveUnit(g, ue);
                ue = FirstOfGroup(g);
            }
            GroupClear(g);
            DestroyGroup(g);
            ue = null;
            g = null;
        }
        
        public method onUnitHit(unit u){
            if (this.hitStructure) {
                return; //do not process units hit if it has already hit a structure
            }

            if (this.checkStructure(u)) {
                this.SpasmicShockStructure(u);
                this.hitStructure = true;
                return;
            } else if (!this.checkTarget(u)) {
                return;
            }

            if (!(LoadBoolean(this.hNuke, GetHandleId(u), 0))) { //make sure unit was not hit by spasmic shock
                this.damage.damageTarget(this.caster, u, this.damageAmount); //damage unit if hit by wave
                SaveBoolean(this.hNuke, GetHandleId(u), 0, true);
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
            
            this.wave = FossuriousNukeWave.create(castX, castY, angle);
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
            FlushParentHashtable(this.hNuke);
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            integer level = GetUnitAbilityLevel(caster, thistype.ABILITY_ID);
            real x = GetSpellTargetX();
            real y = GetSpellTargetY();
            FossuriousNuke.begin(caster, x, y, level);
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
        FossuriousNuke.onSetup.execute();
    }
}

//! endzinc