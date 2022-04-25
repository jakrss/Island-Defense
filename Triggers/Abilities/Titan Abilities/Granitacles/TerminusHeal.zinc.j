//! zinc

library TerminusHeal requires GameTimer, GT, xebasic, xepreload, xecollider, GenericTitanTargets, IsUnitWard, ItemExtras {
    private struct TerminusHeal extends GenericTitanHeal {
        private static constant integer ABILITY_ID = 'TTAE';
		private static constant integer WARD_ID = 'o023';
		private static constant real TICK_DURATION = 0.5;
        private static constant integer EMBLEM_ID = 'I07U';
        private static constant real EMBLEM_INC = 10.0;
		
		method abilityId() -> integer {
            return thistype.ABILITY_ID;
        }
		
		method targetEffect() -> string {
			return "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl";
		}
        
        public method onCheckTarget(unit u) -> boolean {
            return IsUnitHealable(u, this.ward) && GetUnitTypeId(u) != 'o023' && !IsUnitWard(u);
        }

        private method setup(integer level){
            this.damage.dtype = DAMAGE_TYPE_UNIVERSAL;
            this.damage.exception = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(this.targetEffect(), "origin");
            this.damage.forceEffect = true;
            
			this.duration = 12.0;
            //if(UnitHasItemById(this.caster, EMBLEM_ID)) this.duration = this.duration + EMBLEM_INC;
			this.ticks = this.duration / TICK_DURATION;
            if (level == 1){
                this.healAmount = (1200.0 / this.ticks);
                this.effectArea = 400.0;
            }
            else if (level == 2){
                this.healAmount = (1440.0 / this.ticks);
                this.effectArea = 400.0;
            }
            else if (level == 3){
                this.healAmount = (1680.0 / this.ticks);
                this.effectArea = 400.0;
            }
            else if (level == 4){
                this.healAmount = (1920.0 / this.ticks);
                this.effectArea = 400.0;
            }
        }
		
		// Configurable
        private real effectArea = 0.0;
        private real healAmount = 0.0;
		private real duration = 0.0;
        
		// Required
        private unit caster = null;
        private player castingPlayer = null;
        private integer level = 0;
        private xedamage damage = 0;
		private real targetX = 0.0;
		private real targetY = 0.0;
		private GameTimer tickTimer = 0;
		private real ticks = 0.0;
		private unit ward = null;
        
        public method checkTarget(unit u) -> boolean {
            return this.onCheckTarget(u);
        }
		
		private method healArea(){
            group g = CreateGroup();
            unit u = null;
            lightning l = null;
            GroupEnumUnitsInRange(g, GetUnitX(this.ward), GetUnitY(this.ward), this.effectArea, null);
            
            u = FirstOfGroup(g);
            while (u != null){
                if (this.checkTarget(u)){
                    this.damage.damageTarget(this.caster, u, this.healAmount * this.damageFactor());
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
		
		public method tick() -> boolean {
			// We need to quit prematurely (ward was killed)
			if (!UnitAlive(this.ward)) return false;
			
			this.healArea();
			return true;
		}
        
        private static method begin(unit caster, real x, real y, integer level) -> thistype {
            thistype this = thistype.allocate();
            integer i = 0;
            this.caster = caster;
            this.castingPlayer = GetOwningPlayer(this.caster);
            this.level = level;
            this.targetX = x;
            this.targetY = y;

            this.damage = xedamage.create();
            this.damage.damageSelf = true;
            this.damage.damageAllies = true;
            this.damage.damageEnemies = false;
            this.damage.damageNeutral = false;
            this.damage.allyfactor = -1.0;
            this.setup(this.level);
			
			this.ward = CreateUnit(this.castingPlayer, thistype.WARD_ID, this.targetX, this.targetY, bj_UNIT_FACING);
			UnitApplyTimedLife(this.ward, 'BTLF', this.duration);
            
			this.ticks = 0;
            this.tickTimer = GameTimer.newPeriodic(function(GameTimer t){
                thistype this = t.data();
				
				this.ticks = this.ticks + 1;
				// If false then something went wrong, destroy!
				if (this.duration < (TICK_DURATION * this.ticks) || !this.tick()) {
					this.destroy();
				}
            });
            this.tickTimer.setData(this);
            this.tickTimer.start(thistype.TICK_DURATION);
            
            return this;
        }
		
		public method getCaster() -> unit {
			return this.caster;
		}
        
        private method onDestroy(){
			this.tickTimer.deleteLater();
			this.tickTimer = 0;
            this.damage.destroy();
            this.caster = null;
            this.castingPlayer = null;
			this.ward = null;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            real x = GetSpellTargetX();
            real y = GetSpellTargetY();
            integer level = GetUnitAbilityLevel(caster, thistype.ABILITY_ID);
            thistype.begin(caster, x, y, level);
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
        TerminusHeal.onAbilitySetup.execute();
    }
}

//! endzinc