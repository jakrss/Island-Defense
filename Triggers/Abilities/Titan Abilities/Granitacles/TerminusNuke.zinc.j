//! zinc

library TerminusNuke requires GT, xebasic, xemissile, xepreload, GenericTitanTargets {
    private struct TerminusNukeMissile extends xehomingmissile {
        private static constant string MISSILE_EFFECT = "Doodads\\LordaeronSummer\\Terrain\\LoardaeronRockChunks\\LoardaeronRockChunks3.mdl";
        private TerminusNuke object = 0;
        public method setup(TerminusNuke object){
            this.object = object;
            this.fxpath = thistype.MISSILE_EFFECT;
        }
        
        public method onHit(){
            this.object.onHit.execute(this.x, this.y, this.z);
        }
    }
    
    private struct TerminusNuke {
        private static constant integer ABILITY_ID = 'TTAQ';
        private static constant string TARGET_EFFECT = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl";
        
        private method setup(integer level){
            this.damage.dtype = DAMAGE_TYPE_MAGIC;
            this.damage.exception = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(thistype.TARGET_EFFECT, "overhead");
            this.damage.forceEffect = true;
            
            if (level == 1){
                this.damageAmount = 130.0;
            }
            else if (level == 2){
                this.damageAmount = 155.0;
            }
            else if (level == 3){
                this.damageAmount = 180.0;
            }
			this.damageRange = 245.0; // +50 from actual (0103a)
        }
        private unit caster = null;
        private player castingPlayer = null;
        private integer level = 0;
        
        private real damageAmount = 0.0;
		private real damageRange = 0.0;
        private xedamage damage = 0;
		
		private unit target = null;
		private real targetX = 0.0;
		private real targetY = 0.0;
		
	private method damageArea(real x, real y){
            group g = CreateGroup();
            unit u = null;
            GroupEnumUnitsInRange(g, x, y, this.damageRange, null);
            
            u = FirstOfGroup(g);
            while (u != null){
                if (this.checkTarget(u)){
                    if(UnitHasItemById(this.caster, 'I06Z') && IsUnitTitanHunter(u)) this.damageAmount = this.damageAmount * 1.15;
                    this.damage.damageTarget(this.caster, u, this.damageAmount);
                }
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            
            GroupClear(g);
            DestroyGroup(g);
            g = null;
            u = null;
        }
        
        public method onHit(real x, real y, real z) {
			this.damageArea(x, y);
            this.destroy();
        }
        
        public method checkTarget(unit u) -> boolean {
			// Should it check visibility?
            return IsUnitNukable(u, this.caster); // && IsUnitVisible(u, this.castingPlayer);
        }
        
        private method fire() {
            real x = GetUnitX(this.caster);
            real y = GetUnitY(this.caster);
            real z = GetUnitFlyHeight(this.caster);
            TerminusNukeMissile missile = TerminusNukeMissile.create(x, y, z, this.target, 0.0);
            missile.setup(this);
            missile.owner = this.castingPlayer;
			if (this.target == null) {
				missile.setTargetPoint(this.targetX, this.targetY, 0.0);
			}
            missile.launch(1300.0, 0.60);
        }
        
        private static method begin(unit caster, integer level, unit target, real targetX, real targetY) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.level = level;
            this.castingPlayer = GetOwningPlayer(this.caster);
            this.target = target;
			this.targetX = targetX;
			this.targetY = targetY;
	    this.damageAmount = this.damageAmount * getModifiers(this.caster, this.target);
            this.damage = xedamage.create();
            this.damage.damageEnemies = true;
            this.damage.damageNeutral = true;
            this.damage.damageSelf = false;
            this.damage.damageAllies = false;
            this.setup(this.level);
			
			this.fire();
            
            return this;
        }
        
        private method onDestroy(){
			this.target = null;
            this.damage.destroy();
            this.caster = null;
            this.castingPlayer = null;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            integer level = GetUnitAbilityLevel(caster, thistype.ABILITY_ID);
			unit target = GetSpellTargetUnit();
			real targetX = GetSpellTargetX();
			real targetY = GetSpellTargetY();
            thistype.begin(caster, level, target, targetX, targetY);
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
        TerminusNuke.onSetup.execute();
    }
}


//! endzinc