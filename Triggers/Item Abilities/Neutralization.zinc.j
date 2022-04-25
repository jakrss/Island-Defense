//! zinc

library Neutralization requires GameTimer, GT, xebasic, xepreload, LightningUtils {
    private struct Neutralization {
        private static constant integer ABILITY_ID = 'A03E';
        private static constant string TARGET_EFFECT = "Abilities\\Spells\\Orc\\Purge\\PurgeBuffTarget.mdl";
        private static constant string LIGHTNING_EFFECT = "CHIM";
        
		private boolean useLightning = true;
        private method setup(){
            this.bounceRange = 600.0;
            this.bounceTimerDelay = 0.12;
            this.bounceCountMax = 5;
			
			if (!GameSettings.getBool("LIGHTNING_EFFECTS_ENABLED")) {
				this.useLightning = false;
			}
        }
        private unit caster = null;
        private player castingPlayer = null;
        private unit target = null;
        private integer level = 0;
        private boolean allies = false; // Whether allied or enemy mode
        
        private real bounceRange = 0.0;
        private integer bounceCountMax = 0;
        private integer bounceCount = 0;
        private group bouncedUnits = null;
        private real bounceTimerDelay = 0.0;
        private GameTimer bounceTimer = 0;
        
        private lightning bounceLightnings[6];
        
        public method checkTarget(unit u) -> boolean {
            boolean targetForce = false;
            if (this.allies && IsUnitAlly(u, this.castingPlayer)) targetForce = true;
            if (!this.allies && IsUnitEnemy(u, this.castingPlayer)) targetForce = true;
            return !IsUnitInGroup(u, this.bouncedUnits) &&
                   GetOwningPlayer(u) != Player(PLAYER_NEUTRAL_PASSIVE) &&
                   targetForce &&
                   !IsUnitType(u, UNIT_TYPE_STRUCTURE) &&
                   !IsUnitType(u, UNIT_TYPE_MECHANICAL) &&
                    UnitAlive(u);
        }
        
        public method getClosestTarget(unit target) -> unit {
            group g = CreateGroup();
            unit u = null;
            unit newTarget = null;
            real dx = 0.0;
            real dy = 0.0;
            real closestDist = this.bounceRange + 50.0;
            real distance = 0.0;
            
            GroupEnumUnitsInRange(g, GetUnitX(target), GetUnitY(target), this.bounceRange, null);
            
            u = FirstOfGroup(g);
            while (u != null){
                if (this.checkTarget(u)){
                    dx = GetUnitX(target) - GetUnitX(u);
                    dy = GetUnitY(target) - GetUnitY(u);
                    distance = SquareRoot(dx * dx + dy * dy);
                    if (distance < closestDist){
                        closestDist = distance;
                        newTarget = u;
                    }
                }
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            
            GroupClear(g);
            DestroyGroup(g);
            g = null;
            u = null;
            
            return newTarget;
        }
        
        private method onUnitHit(unit u) {
            DestroyEffectTimed(AddSpecialEffectTarget(thistype.TARGET_EFFECT, u, "head"), 3.0);
            UnitRemoveBuffs(u, true, true);
            UnitRemoveAbility(u, 'B01T');
            //UnitRemoveAbility(u, 'B00W'); // Does nothing?
            UnitRemoveAbility(u, 'BHav');
        }
        
        public method tick(){
            unit lastTarget = this.target;
            if (this.bounceCount >= 0) {
                this.target = this.getClosestTarget(this.target);
            }
            else {
                lastTarget = this.caster;
            }
            
            if (this.target != null){
                if (lastTarget != null && this.useLightning) {
                    this.bounceLightnings[this.bounceCount+1] =
                        CreateLightningBetweenUnits(thistype.LIGHTNING_EFFECT, false, lastTarget, this.target);
                }
                this.onUnitHit.execute(this.target);
                
                GroupAddUnit(this.bouncedUnits, this.target);
                this.bounceCount = this.bounceCount + 1;
            }
            else {
                // Couldn't find any targets... stop ticking
                this.destroy();
            }
            
        }
        
        private static method begin(unit caster, unit target) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.target = target;
            this.bounceCount = -1;
            this.bouncedUnits = CreateGroup();
            this.castingPlayer = GetOwningPlayer(this.caster);
            GroupAddUnit(this.bouncedUnits, target);
            
            this.setup();
            
            if (IsUnitAlly(this.target, this.castingPlayer)) {
                this.allies = true;
            }
            
            this.bounceTimer = GameTimer.newPeriodic(function(GameTimer t){
                thistype this = t.data();
                this.tick();
                if (this.bounceCount >= this.bounceCountMax){
                    this.destroy();
                }
            }).start(this.bounceTimerDelay);
            this.bounceTimer.setData(this);
            
            return this;
        }
        
        private method onDestroy(){
            integer i = 0;
			if (this.useLightning) {
				for (0 <= i < this.bounceCount + 1){
					if (this.bounceLightnings[i] != null){
						ReleaseLightning(this.bounceLightnings[i]);
						this.bounceLightnings[i] = null;
					}
				}
			}
            GroupClear(this.bouncedUnits);
            DestroyGroup(this.bouncedUnits);
            this.bounceTimer.deleteLater();
            this.caster = null;
            this.castingPlayer = null;
            this.target = null;
            this.bouncedUnits = null;
        }
        
        private static method onCast(){
            unit u = GetSpellTargetUnit();
            unit caster = GetSpellAbilityUnit();
            thistype.begin(caster, u);
        }
        
        public static method onSetup(){
            trigger t = CreateTrigger();
            GT_RegisterStartsEffectEvent(t, thistype.ABILITY_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            t = null;
        }
    }
    
    private function onInit(){
        Neutralization.onSetup();
    }
}


//! endzinc