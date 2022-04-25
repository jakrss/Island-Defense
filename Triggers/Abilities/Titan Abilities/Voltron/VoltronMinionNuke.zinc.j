//! zinc

// TODO(rory): Make this more generic
library VoltronMinionNuke requires GenericTitanTargets {
    private struct VoltronMinionNuke extends GenericTitanNuke {
        private static constant integer ABILITY_ID = 'TVNQ';
        private static constant string TARGET_EFFECT = "war3mapImported\\LightningSphere_FX.mdx";

        public method abilityId() -> integer {
            return thistype.ABILITY_ID;
        }
        
        public method missileEffect() -> string {
            return "war3mapImported\\OrbOfLightning.mdx";
        }

        private method onSetup(integer level){
            this.damage.dtype = DAMAGE_TYPE_MAGIC;
            this.damage.exception = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(thistype.TARGET_EFFECT, "chest");
            this.damage.forceEffect = true;
            
            if (level == 1){
                this.damageAmount = 130.0;
                this.distance = 650.0;
            }
            else if (level == 2){
                this.damageAmount = 155.0;
                this.distance = 650.0;
            }
            else if (level == 3){
                this.damageAmount = 180.0;
                this.distance = 650.0;
            }
            
            this.delta = 35.0;
        }
        
        private unit caster = null;
        private player castingPlayer = null;
        private integer level = 0;
        private real distance = 0.0;
        private real damageAmount = 0.0;
        private real delta = 0.0;
        private xedamage damage = 0;
        private group targets = null;
        
        public method checkTarget(unit u) -> boolean {
            return !IsUnit(u, this.caster) && IsUnitNukable(u, this.caster) && IsUnitVisible(u, this.castingPlayer);
        }
        
        public method onUnitHit(unit u) -> boolean {
            this.damage.damageTarget(this.caster, u, this.damageAmount);
            GroupRemoveUnit(this.targets, u);
            if (FirstOfGroup(this.targets) == null) {
                // No more units to hit, destroy this object in NukeMissle
                return false;
            }
            return true;
        }
        
        public method getCaster() -> unit {
            return this.caster;
        }
        
        public method fireAtTarget(unit u){
            GroupAddUnit(this.targets, u);
            NukeMissile.FireAtTarget(this, GetUnitX(this.caster), GetUnitY(this.caster), u);
        }
        
        public static method pointInCone(real baseX, real baseY, real distance, real angle, real delta, real x, real y) -> boolean {
            real posAngle = Atan2(y - baseY, x - baseX) * bj_RADTODEG;
            posAngle = RAbsBJ(posAngle - angle);
            if (posAngle > 180) posAngle = 360 - posAngle;
            return posAngle <= delta;
        }
        
        private method acquireTargets(unit target, real x, real y) {
            real pointX = x;
            real pointY = y;
            real castX = GetUnitX(this.caster);
            real castY = GetUnitY(this.caster);
            real angle = Atan2(pointY - castY, pointX - castX) * bj_RADTODEG;
            real endX = castX + this.distance * Cos(angle * bj_DEGTORAD);
            real endY = castY + this.distance * Sin(angle * bj_DEGTORAD);
            unit u = null;
            group g = CreateGroup();
            
            GroupEnumUnitsInRange(g, castX, castY, this.distance, null);
            
            if (target != null && this.checkTarget(target)) {
                // Hit the main target (fo sho!)
                this.fireAtTarget(target);
            }
            
            u = FirstOfGroup(g);
            while (u != null) {
                if (u != target && 
                    this.checkTarget(u) &&
                    thistype.pointInCone(castX, castY, this.distance, angle, this.delta, GetUnitX(u), GetUnitY(u))) {
                    this.fireAtTarget(u);
                }
                
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            
            DestroyGroup(g);
            g = null;
            u = null;
        }
        
        private static method begin(unit caster, unit u, real x, real y, integer level) -> thistype {
            thistype this = thistype.allocate();
            this.level = level; // Sigh
            this.caster = caster;
            this.castingPlayer = GetOwningPlayer(this.caster);
            this.damage = xedamage.create();
            this.targets = CreateGroup();
            
            // NOTE(rory): Not setup, because we're not implementing the correct module
            this.onSetup(this.level);
			
			if (u != null) {
				x = GetUnitX(u);
				y = GetUnitY(u);
			}
            
            this.acquireTargets(u, x, y);
            return 0;
        }
        
        private method onDestroy(){
            GroupClear(this.targets);
            DestroyGroup(this.targets);
            this.targets = null;
            this.damage.destroy();
            this.caster = null;
            this.castingPlayer = null;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            integer level = GetUnitAbilityLevel(caster, thistype.ABILITY_ID);
            unit u = GetSpellTargetUnit();
			real x = GetSpellTargetX();
			real y = GetSpellTargetY();
			
            VoltronMinionNuke.begin(caster, u, x, y, level);
        }
        
        public static method onAbilitySetup(){
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
        VoltronMinionNuke.onAbilitySetup.execute();
    }
}


//! endzinc