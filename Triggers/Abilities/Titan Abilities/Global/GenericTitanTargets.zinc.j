//! zinc

library GenericTitanTargets requires IsUnitWard, GameTimer, GT, xebasic, xepreload, UnitAlive, LightningUtils, IsUnitWall, IsUnitTitanHunter, ItemExtras, Nukes, Healing {
    public function IsUnitNukable(unit u, unit caster) -> boolean {
        player p = GetOwningPlayer(caster); // Apparently player handles do not leak, so this is good!
        return (IsUnitEnemy(u, p) ||
                GetOwningPlayer(u) == Player(PLAYER_NEUTRAL_PASSIVE)) && // Alliances
               !IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) &&                 // Magic
               !IsUnitType(u, UNIT_TYPE_STRUCTURE) &&                    // Organic only
               !IsUnitType(u, UNIT_TYPE_MECHANICAL) &&
               !IsUnitWard(u) &&                                         // No wards
                UnitAlive(u);                                         // Is Alive
    }

    public function IsUnitNukableStructure(unit u, unit caster) -> boolean {
        player p = GetOwningPlayer(caster); // Apparently player handles do not leak, so this is good!
        return (IsUnitEnemy(u, p) ||
                GetOwningPlayer(u) == Player(PLAYER_NEUTRAL_PASSIVE)) && // Alliances
                IsUnitType(u, UNIT_TYPE_STRUCTURE) &&                    // Structures only
                UnitAlive(u);                                          // Is Alive
    }
    
    public function IsUnitHealable(unit u, unit caster) -> boolean {
        player p = GetOwningPlayer(caster);
        return (IsUnitAlly(u, p) &&
                GetOwningPlayer(u) != Player(PLAYER_NEUTRAL_PASSIVE)) &&
               !IsUnitType(u, UNIT_TYPE_STRUCTURE) &&
               !IsUnitType(u, UNIT_TYPE_MECHANICAL) &&
               !IsUnitWard(u) &&
                UnitAlive(u) &&
               (GetUnitState(u, UNIT_STATE_LIFE) < GetUnitState(u, UNIT_STATE_MAX_LIFE));
    }
    
    public interface GenericTitanNuke {
        method abilityId() -> integer;
        method targetEffect() -> string = ""; 
        method missileEffect() -> string = ""; 
        method onSetup(integer level) = null;
        method onCheckTarget(unit u) -> boolean = true;
        method onUnitHit(unit u) -> boolean = false;
        method getCaster() -> unit;
        method tick() -> boolean = false;
    }
	
	public interface GenericTitanHeal {
		method damageFactor() -> real = 1.00;
        method abilityId() -> integer; // 'TLAE'
        method targetEffect() -> string = "Abilities\\Spells\\Orc\\HealingWave\\HealingWaveTarget.mdl"; 
		method lightningEffect() -> string = "DRAM";
        method onSetup(integer level) = null;
        method onCheckTarget(unit u) -> boolean = true;
		method getCaster() -> unit;
	}
    
    
    public struct NukeMissile extends xehomingmissile {
        private GenericTitanNuke object = 0;
        public method setup(GenericTitanNuke object){
            this.object = object;
            this.fxpath = object.missileEffect();
            this.owner = GetOwningPlayer(object.getCaster());
        }
        
        public method onHit(){
            // the missile object will destroy itself after this
            if (this.object.onUnitHit(this.targetUnit)) {
                this.object.tick();
            }
            else {
                this.object.destroy();
                this.object = 0;
            }
        }
        
        public static method FireAtTarget(GenericTitanNuke object, real x, real y, unit u) {
            real z = 40.0;
            thistype missile = thistype.create(x, y, z, u, 0.0);
            missile.setup(object);
            missile.launch(900.0, 0.0); // speed
        }
    }
    
    public module GenericTitanBounceNuke {
		public method getCaster() -> unit {
			return this.caster;
		}
        private method setup(integer level){
            // Load defaults
            this.damage.dtype = DAMAGE_TYPE_MAGIC;
            this.damage.exception = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(this.targetEffect(), "origin");
            this.damage.forceEffect = true;
            
            this.bounceAfterBlock = true;
            
            this.bounceRange = 500.0;
            this.bounceTimerDelay = 0.30;
            
            if (level == 1){
                // 130 damage, 4 bounces
                this.damageAmount = 130.0;
                this.bounceCountMax = 4;
            }
            else if (level == 2){
                // 155 damage, 5 bounces
                this.damageAmount = 155.0;
                this.bounceCountMax = 5;
            }
            else if (level == 3){
                // 180 damage, 6 bounces
                this.damageAmount = 180.0;
                this.bounceCountMax = 6;
            }
			//Nukemaster:
			if(UnitHasItemById(this.caster, 'I08L')) this.damageAmount = this.damageAmount * 1.20;
            
            // Run custom setup
            this.onSetup(level);
        }
        public unit caster = null;
        public player castingPlayer = null;
        public unit target = null;
        public integer level = 0;
        private real lastX = 0.0;
        private real lastY = 0.0;
        public real damageAmount = 0.0;
        public real bounceRange = 0.0;
        public integer bounceCountMax = 0;
        public integer bounceCount = 0;
        public group bouncedUnits = null;
        public real bounceTimerDelay = 0.0;
        public GameTimer bounceTimer = 0;
        public xedamage damage = 0;
        public boolean bounceAfterBlock = false;
        public boolean useMissiles = false;
        
        public method checkTarget(unit u) -> boolean {
            return this.onCheckTarget(u);
        }
        
        public method onUnitHit(unit u) -> boolean {
            this.damageAmount = this.damageAmount;
			//Moltenious Nuke burn on Incinerated targets:
			if(GetUnitTypeId(caster)=='E00C' && GetUnitAbilityLevel(target, 'B03Q') > 0) {
				MolteniousNukeBurn(caster, target);
			}
			//---------------------------------------------
            return this.damage.damageTarget(this.caster, u, this.damageAmount);
        }
        
        public method getClosestTarget(real x, real y) -> unit {
            group g = CreateGroup();
            unit u = null;
            unit newTarget = null;
            real dx = 0.0;
            real dy = 0.0;
            real closestDist = this.bounceRange + 50.0;
            real distance = 0.0;
            
            GroupEnumUnitsInRange(g, x, y, this.bounceRange, null);
            
            u = FirstOfGroup(g);
            while (u != null){
                if (this.checkTarget(u)){
                    dx = x - GetUnitX(u);
                    dy = y - GetUnitY(u);
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
        
        public method tick() -> boolean {
            if (this.target == null) {
                // Find Target
                this.target = this.getClosestTarget(this.lastX, this.lastY);
            }
            if (this.target != null){
                // Execute!
                if (this.useMissiles) {
                    NukeMissile.FireAtTarget(this, this.lastX, this.lastY, this.target);
                }
                else {
                    if (!this.onUnitHit(this.target) && !this.bounceAfterBlock){
                        // Damage was blocked! Cancel bouncing.
                        this.destroy();
                        return false;
                    }
                }
                GroupAddUnit(this.bouncedUnits, this.target);
                this.bounceCount = this.bounceCount + 1;
                
                this.lastX = GetUnitX(this.target);
                this.lastY = GetUnitY(this.target);
                
                // Next Target Required
                this.target = null;
                return true;
            }
            this.destroy();
            return false;
        }
        
        private static method begin(unit caster, unit target) -> thistype {
            thistype this = thistype.allocate();
            integer level = GetUnitAbilityLevel(caster, this.abilityId());
            this.caster = caster;
            this.target = target;
            this.level = level;
            this.bounceCount = -1; // Initial hit is a "bounce"
            this.bouncedUnits = CreateGroup();
            this.castingPlayer = GetOwningPlayer(this.caster);
            
            this.damage = xedamage.create();
            this.setup(this.level);
            
            this.lastX = GetUnitX(this.caster);
            this.lastY = GetUnitY(this.caster);
            
            if (this.tick() && !this.useMissiles) {
                this.bounceTimer = GameTimer.newPeriodic(function(GameTimer t){
                    thistype this = t.data();
                    this.tick();
                    if (this.bounceCount >= this.bounceCountMax){
                        this.destroy();
                    }
                }).start(this.bounceTimerDelay);
                this.bounceTimer.setData(this);
            }
            
            return this;
        }
        
        private method onDestroy(){
            if (this.bouncedUnits != null) {
                GroupClear(this.bouncedUnits);
                DestroyGroup(this.bouncedUnits);
                this.bouncedUnits = null;
            }
            if (this.damage != 0) {
                this.damage.destroy();
                this.damage = 0;
            }
            if (this.bounceTimer != 0) {
                this.bounceTimer.deleteLater();
                this.bounceTimer = 0;
            }
            this.caster = null;
            this.castingPlayer = null;
            this.target = null;
        }
        
        private static method onCast(){
            unit u = GetSpellTargetUnit();
            unit caster = GetSpellAbilityUnit();
            thistype.begin(caster, u);
        }
        
        public static method onAbilitySetup(){
            trigger t = CreateTrigger();
            thistype this = thistype.allocate();
            integer id = this.abilityId();
            this.destroy();
            GT_RegisterStartsEffectEvent(t, id);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            XE_PreloadAbility(id);
        }
		
		public static method onInit() {
			thistype.onAbilitySetup.execute();
		}
    }
	
	type UnitFilter extends function(unit) -> boolean;
	
	public module GenericTitanBounceHeal {
		public method getCaster() -> unit {
			return this.caster;
		}
		private boolean useLightning = true;
        private method setup(integer level){
            this.damage.dtype = DAMAGE_TYPE_UNIVERSAL;
            this.damage.exception = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(this.targetEffect(), "origin");
            this.damage.forceEffect = true;
            
            this.bounceRange = 600.0;
            this.bounceTimerDelay = 0.12;
            
            if (level == 1){
                this.damageAmount = 300.0;
                this.bounceCountMax = 1;
            }
            else if (level == 2){
                this.damageAmount = 500.0;
                this.bounceCountMax = 2;
            }
            else if (level == 3){
                this.damageAmount = 700.0;
                this.bounceCountMax = 2;
            }
            else if (level == 4){
                this.damageAmount = 900.0;
                this.bounceCountMax = 3;
            }
			
	    if (!GameSettings.getBool("LIGHTNING_EFFECTS_ENABLED")) {
	        this.useLightning = false;
	    }	
            // Run custom setup
            this.onSetup(level);
        }
        public unit caster = null;
        public player castingPlayer = null;
        public unit target = null;
        public integer level = 0;
        
        public real damageAmount = 0.0;
        public real bounceRange = 0.0;
        public integer bounceCountMax = 0;
        public integer bounceCount = 0;
        public group bouncedUnits = null;
        public real bounceTimerDelay = 0.0;
        public GameTimer bounceTimer = 0;
        public xedamage damage = 0;
        
        public lightning bounceLightnings[4];
		
		public method checkTarget(unit u) -> boolean {
            return this.onCheckTarget(u);
        }
		
		public method getWeakestTarget(real x, real y, real range) -> unit {
            group g = CreateGroup();
            unit u = null;
            unit newTarget = null;
            real weakestHealth = 1.0;
            real health = 0.0;
            
            GroupEnumUnitsInRange(g, x, y, range, null);
            
            u = FirstOfGroup(g);
            while (u != null){
				if (this.checkTarget(u)) {
					health = (GetUnitState(u, UNIT_STATE_LIFE) / GetUnitState(u, UNIT_STATE_MAX_LIFE));
					if (health < weakestHealth || newTarget == null){
						weakestHealth = health;
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
        
        public method getClosestTarget(real x, real y) -> unit {
            group g = CreateGroup();
            unit u = null;
            unit newTarget = null;
            real dx = 0.0;
            real dy = 0.0;
            real closestDist = this.bounceRange + 50.0;
            real distance = 0.0;
            
            GroupEnumUnitsInRange(g, x, y, this.bounceRange, null);
            
            u = FirstOfGroup(g);
            while (u != null){
                if (this.checkTarget(u)){
                    dx = x - GetUnitX(u);
                    dy = y - GetUnitY(u);
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
        
        public method tick(){
            unit lastTarget = this.target;
			real x = GetUnitX(this.target);
			real y = GetUnitY(this.target);
			if (GameSettings.getBool("TITAN_HEALING_SMART_HEAL")) {
				this.target = this.getWeakestTarget(x, y, this.bounceRange);
			}
			else {
				this.target = this.getClosestTarget(x, y);
			}
            
            if (this.target != null){
				if (this.useLightning) {
					this.bounceLightnings[this.bounceCount] = CreateLightningBetweenUnits(this.lightningEffect(), true,
                                                              this.target, lastTarget);
			    }
			    
                this.damage.damageTarget(this.caster, this.target, this.damageAmount * this.damageFactor());
                GroupAddUnit(this.bouncedUnits, this.target);
                this.bounceCount = this.bounceCount + 1;
            }
            else {
                // Couldn't find any targets... stop ticking
                this.destroy();
            }
            
        }
        
        private static method begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            integer level = GetUnitAbilityLevel(caster, this.abilityId());
            this.caster = caster;
            this.target = this.caster;
            this.level = level;
            this.bounceCount = 0;
            this.bouncedUnits = CreateGroup();
			this.bounceTimer = 0;
            this.castingPlayer = GetOwningPlayer(this.caster);
            GroupAddUnit(this.bouncedUnits, target);
            
            this.damage = xedamage.create();
            this.damage.damageSelf = true;
            this.damage.damageAllies = true;
            this.damage.damageEnemies = false;
            this.damage.damageNeutral = false;
            this.damage.allyfactor = -1.0;
            this.setup(this.level);
            this.damage.damageTarget(this.caster, this.target, this.damageAmount * this.damageFactor());
			
			if (this.bounceCountMax > 0) {
				this.bounceTimer = GameTimer.newPeriodic(function(GameTimer t){
					thistype this = t.data();
					this.tick();
					if (this.bounceCount >= this.bounceCountMax){
						this.destroy();
					}
				}).start(this.bounceTimerDelay);
				this.bounceTimer.setData(this);
			}
			else {
				this.destroy();
			}
            
            return this;
        }
        
        private method onDestroy(){
            integer i = 0;
			if (this.useLightning) {
				for (0 <= i < this.bounceCount){
					if (this.bounceLightnings[i] != null){
						ReleaseLightning(this.bounceLightnings[i]);
						this.bounceLightnings[i] = null;
					}
				}
			}
            GroupClear(this.bouncedUnits);
            DestroyGroup(this.bouncedUnits);
            this.damage.destroy();
			if (this.bounceTimer != 0) {
				this.bounceTimer.deleteLater();
			}
            this.caster = null;
            this.castingPlayer = null;
            this.target = null;
            this.bouncedUnits = null;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            thistype.begin(caster);
        }
        
        public static method onAbilitySetup(){
            trigger t = CreateTrigger();
            thistype this = thistype.allocate();
            integer id = this.abilityId();
            this.destroy();
            GT_RegisterStartsEffectEvent(t, id);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            XE_PreloadAbility(id);
        }
		
		public static method onInit() {
			thistype.onAbilitySetup.execute();
		}
    }
	
	public module GenericTitanAreaHeal {
		public method getCaster() -> unit {
			return this.caster;
		}
		private boolean useLightning = true;
        private method setup(integer level){
            this.damage.dtype = DAMAGE_TYPE_UNIVERSAL;
            this.damage.exception = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(this.targetEffect(), "chest");
            this.damage.forceEffect = true;
            
            if (level == 1){
                this.healAmount = 300.0;
                this.healRange = 500.0;
            }
            else if (level == 2){
                this.healAmount = 500.0;
                this.healRange = 600.0;
            }
            else if (level == 3){
                this.healAmount = 700.0;
                this.healRange = 600.0;
            }
            else if (level == 4){
                this.healAmount = 900.0;
                this.healRange = 700.0;
            }
			
			if (!GameSettings.getBool("LIGHTNING_EFFECTS_ENABLED")) {
				this.useLightning = false;
			}
			
            // Run custom setup
            this.onSetup(level);
        }
        public unit caster = null;
        private player castingPlayer = null;
        private integer level = 0;
        
        public real healAmount = 0.0;
        public real healRange = 0.0;
        public xedamage damage = 0;
        
        public method checkTarget(unit u) -> boolean {
			return this.onCheckTarget(u);
        }
        
        private method healArea(){
            group g = CreateGroup();
            unit u = null;
            lightning l = null;
            GroupEnumUnitsInRange(g, GetUnitX(this.caster), GetUnitY(this.caster), this.healRange, null);
            
            u = FirstOfGroup(g);
            while (u != null){
                if (this.checkTarget(u)){
                    this.damage.damageTarget(this.caster, u, this.healAmount * this.damageFactor());
                    
					if (this.useLightning) {
						l = CreateLightningBetweenUnits(this.lightningEffect(), true, u, this.caster);
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
        
        private static method begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            integer level = GetUnitAbilityLevel(caster, this.abilityId());
            this.caster = caster;
            this.level = level;
            this.castingPlayer = GetOwningPlayer(this.caster);
            
            this.damage = xedamage.create();
            this.damage.damageSelf = true;
            this.damage.damageAllies = true;
            this.damage.damageEnemies = false;
            this.damage.damageNeutral = false;
            this.damage.allyfactor = -1.0;
            this.setup(this.level);
            
            this.healArea();
            
            return this;
        }
        
        private method onDestroy(){
            this.damage.destroy();
            this.caster = null;
            this.castingPlayer = null;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            thistype.begin(caster);
        }
        
        public static method onAbilitySetup(){
            trigger t = CreateTrigger();
            thistype this = thistype.allocate();
            integer id = this.abilityId();
            this.destroy();
            GT_RegisterStartsEffectEvent(t, id);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            XE_PreloadAbility(id);
        }
		
		public static method onInit() {
			thistype.onAbilitySetup.execute();
		}
    }
    
    public module TitanAttackBounce {
		public method getCaster() -> unit {
			return this.attacker;
		}
        private method setup(integer level){
            // Load defaults
            this.damage.dtype = DAMAGE_TYPE_UNIVERSAL;
            this.damage.exception = UNIT_TYPE_DEAD;
            this.damage.useSpecialEffect(this.targetEffect(), "origin");
            this.damage.forceEffect = true;
            
            this.bounceAfterBlock = true;
            
            this.bounceRange = 200.0;
            this.bounceTimerDelay = 0.30;
            this.bounceCountMax = 1*level;
            this.damageAmount = GetEventDamage() * (level*.10);
                
            // Run custom setup
            this.onSetup(level);
        }
        public unit attacker = null;
        public player attackingPlayer = null;
        public unit target = null;
        public integer level = 0;
        private real lastX = 0.0;
        private real lastY = 0.0;
        public real damageAmount = 0.0;
        public real bounceRange = 0.0;
        public integer bounceCountMax = 0;
        public integer bounceCount = 0;
        public group bouncedUnits = null;
        public real bounceTimerDelay = 0.0;
        public GameTimer bounceTimer = 0;
        public xedamage damage = 0;
        public boolean bounceAfterBlock = false;
        public boolean useMissiles = false;
        private static integer abilityId = 'TVAR';
        
        public method checkTarget(unit u) -> boolean {
            return this.onCheckTarget(u);
        }
        
        public method onUnitHit(unit u) -> boolean {
            return this.damage.damageTarget(this.attacker, u, this.damageAmount);
        }
        
        public method getClosestTarget(real x, real y) -> unit {
            group g = CreateGroup();
            unit u = null;
            unit newTarget = null;
            real dx = 0.0;
            real dy = 0.0;
            real closestDist = this.bounceRange + 50.0;
            real distance = 0.0;
            
            GroupEnumUnitsInRange(g, x, y, this.bounceRange, null);
            
            u = FirstOfGroup(g);
            while (u != null){
                if (this.checkTarget(u)){
                    dx = x - GetUnitX(u);
                    dy = y - GetUnitY(u);
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
        
        public method tick() -> boolean {
            if (this.target == null) {
                // Find Target
                this.target = this.getClosestTarget(this.lastX, this.lastY);
            }
            if (this.target != null){
                // Execute!
                if (this.useMissiles) {
                    NukeMissile.FireAtTarget(this, this.lastX, this.lastY, this.target);
                }
                else {
                    if (!this.onUnitHit(this.target) && !this.bounceAfterBlock){
                        // Damage was blocked! Cancel bouncing.
                        this.destroy();
                        return false;
                    }
                }
                GroupAddUnit(this.bouncedUnits, this.target);
                this.bounceCount = this.bounceCount + 1;
                this.lastX = GetUnitX(this.target);
                this.lastY = GetUnitY(this.target);
                
                // Next Target Required
                this.target = null;
                return true;
            }
            this.destroy();
            return false;
        }
        
        private static method begin(unit attacker, unit target) -> thistype {
            thistype this = thistype.allocate();
            integer level = GetUnitAbilityLevel(attacker, this.abilityId);
            this.attacker = attacker;
            this.target = target;
            this.level = level;
            this.bounceCount = -1; // Initial hit is a "bounce"
            this.bouncedUnits = CreateGroup();
            this.attackingPlayer = GetOwningPlayer(this.attacker);
            
            this.damage = xedamage.create();
            this.setup(this.level);
            
            this.lastX = GetUnitX(this.attacker);
            this.lastY = GetUnitY(this.attacker);
            
            if (this.tick() && !this.useMissiles) {
                this.bounceTimer = GameTimer.newPeriodic(function(GameTimer t){
                    thistype this = t.data();
                    this.tick();
                    if (this.bounceCount >= this.bounceCountMax){
                        this.destroy();
                    }
                }).start(this.bounceTimerDelay);
                this.bounceTimer.setData(this);
            }
            
            return this;
        }
        
        private method onDestroy(){
            if (this.bouncedUnits != null) {
                GroupClear(this.bouncedUnits);
                DestroyGroup(this.bouncedUnits);
                this.bouncedUnits = null;
            }
            if (this.damage != 0) {
                this.damage.destroy();
                this.damage = 0;
            }
            if (this.bounceTimer != 0) {
                this.bounceTimer.deleteLater();
                this.bounceTimer = 0;
            }
            this.attacker = null;
            this.attackingPlayer = null;
            this.target = null;
        }
        
        private static method onAttack(unit u, unit attacker){
            thistype.begin(attacker, u);
        }
        
        public static method onAttackSetup(){
            trigger t = CreateTrigger();
            Damage_RegisterEvent(t);
            TriggerAddCondition(t, Condition(function() -> boolean {
                unit a = GetEventDamageSource();
                unit u = GetTriggerUnit();
                real damage = GetEventDamage();
                //Purely checking for Titan doing damage and ignoring fiery gauntlets damage
                if (UnitManager.isTitan(a) && Damage_IsAttack() && damage > 11.0 && IsUnitWall(u) && GetUnitAbilityLevel(a, thistype.abilityId) > 0) {
                    thistype.onAttack(u, a);
                }
                a = null;
                u = null;
                return false;
            }));
            t=null;
        }
		
		public static method onInit() {
			thistype.onAttackSetup.execute();
		}
    }
}

//! endzinc