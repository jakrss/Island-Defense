//! zinc

library FossuriousUlt requires GameTimer, GT, xepreload, GenericTitanTargets, IsUnitWard, ItemExtras, UnitStatus, BUM, ABMA {
    private struct FossuriousUlt {
        public static hashtable hCocMin = InitHashtable();
        
        private static constant integer ABILITY_ID = 'A0QU';
        private static constant integer FOSSURIOUS_ID = 'E012';
        private static constant integer FOSSURIOUS_MINION_ID = 'U01A';
        private static constant integer CRYPT_SWARMER_ID = 'U01A';
        private static constant integer COCOON_ID = 'E015';
		private static constant real TICK_DURATION = 0.5; //how often to check for cocoons in range
        private static constant integer DAMAGE_INCREASE = 15;

		
		method abilityId() -> integer {
            return thistype.ABILITY_ID;
        }
		
		method targetEffect() -> string {
			return "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl";
		}
        
        public method onCheckTarget(unit u) -> boolean {
            return IsUnitHealable(u, this.caster) && !IsUnitWard(u);
        }

        private method setup(){
			this.duration = 30.0;
			this.ticks = this.duration / TICK_DURATION;
            this.effectArea = 500.0;  //area around Foss to create cocoons
            this.healArea = 650.0; //range Foss needs to be in of cocoons for heal AoE

            this.groupCocoon = CreateGroup();
        }
		
		// Configurable
        private real effectArea = 0.0;
        private real healArea = 0.0;
        private real healAmount = 0.0;
		private real duration = 0.0;
        private integer damageMultiplier = 0;
        
		// Required
        private unit caster = null;
        private integer totalCocoon = 0;
        private group groupCocoon = null;
        private group groupMinion = null;
		private GameTimer tickTimer = 0;
		private real ticks = 0.0;

        
        public method checkTarget(unit u) -> boolean {
            return this.onCheckTarget(u);
        }

        private method increaseDamage() {
            //increase damage of this.caster by 15 * this.damageMultiplier (coocoons out of range)
            ABMAAddUnitDamageBonus(this.caster, this.damageMultiplier * this.DAMAGE_INCREASE, this.TICK_DURATION, false);
        }
		
		private method healAoE(){
            group g = CreateGroup();
            unit u = null;
            integer cocoon = 0;
            filterfunc uFilter = Filter(function() -> boolean {
                return IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE) == false && UnitAlive(GetFilterUnit());
            });
            
            GroupEnumUnitsInRange(g, GetUnitX(this.caster), GetUnitY(this.caster), this.healArea, uFilter);
            
            u = FirstOfGroup(g);
            while (u != null){
                if (GetUnitTypeId(u) == this.COCOON_ID) { //unit is a cocoon
                    cocoon = cocoon + 1;
                }
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            GroupClear(g);
            DestroyGroup(g);

            this.damageMultiplier = this.totalCocoon - cocoon; //for every cocoon out of range, increase damage
            this.healAmount = ((getMaxHealth(this.caster) * 0.02 * cocoon) / this.ticks); //Get amount to heal for this tick
            if (this.checkTarget(this.caster)){
                healUnit(this.caster, this.healAmount);
            }

            g = null;
            u = null;
        }

        private method transformCocoon() {
            group g = CreateGroup();
            unit uMinion = null;
            unit uCocoon = null;
            filterfunc uFilter = Filter(function() -> boolean {
                return IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE) == false && UnitAlive(GetFilterUnit());
            });

            GroupEnumUnitsInRange(g, GetUnitX(this.caster), GetUnitY(this.caster), this.effectArea, uFilter);
            this.totalCocoon = 0;
            uMinion = FirstOfGroup(g);
            while (uMinion != null){
                if ((GetUnitTypeId(uMinion) == this.FOSSURIOUS_MINION_ID) || (GetUnitTypeId(uMinion) == this.CRYPT_SWARMER_ID)) { //unit is a minion / crypt swarmer
                    //hide minion
                    PauseUnit(uMinion, true);
                    ShowUnit(uMinion, false);
                    //Create cocoon at minion location
                    uCocoon=CreateUnit(GetOwningPlayer(uMinion), this.COCOON_ID, GetUnitX(uMinion), GetUnitY(uMinion), 0);
                    SaveUnitHandle(FossuriousUlt.hCocMin, GetHandleId(uCocoon), 0, uMinion);
                    //Add unit to cocoon group, increment counter
                    GroupAddUnit(this.groupCocoon, uCocoon);
                    this.totalCocoon = this.totalCocoon + 1;
                }
                GroupRemoveUnit(g, uMinion);
                uMinion = FirstOfGroup(g);
            }
            
            GroupClear(g);
            DestroyGroup(g);
            g = null;
            uMinion = null;
            uCocoon = null;
        }

        private method transformMinion() {
            //spell has ended, convert all remaining cocoons back to minions
            unit uCocoon = null;
            unit uMinion = null;


            //LOOP through remaining cocoon units and delete them
            uCocoon = FirstOfGroup(this.groupCocoon);
            while (uCocoon != null){
                uMinion = LoadUnitHandle(FossuriousUlt.hCocMin, GetHandleId(uCocoon), 0);
                //remove unit from cocoon group
                GroupRemoveUnit(this.groupCocoon, uCocoon);
                RemoveUnit(uCocoon); //do we want to kill here for death animation?

                //unhide minion
                PauseUnit(uMinion, false);
                ShowUnit(uMinion, true);
                SetUnitOwner(uMinion, GetOwningPlayer(uCocoon), true); //change minion owner to whoever owned the cocoon in case ownership change occured during ult
                uCocoon = FirstOfGroup(this.groupCocoon);
            }
            GroupClear(this.groupCocoon);

            this.totalCocoon = 0;
            uMinion = null;
            uCocoon = null;
        }

        public static method onCocoonDeath(unit uCocoon) {
            unit uMinion;

            uMinion = LoadUnitHandle(FossuriousUlt.hCocMin, GetHandleId(uCocoon), 0);
            PauseUnit(uMinion, false);
            ShowUnit(uMinion, true);
            SetUnitOwner(uMinion, GetOwningPlayer(uCocoon), true); //change minion owner to whoever owned the cocoon in case ownership change occured during ult
        }
		
		public method tick() -> boolean {
			// We need to quit prematurely (all cocoons were killed)
			if (this.totalCocoon == 0) return false;
			
			this.healAoE();
            if (this.damageMultiplier > 0) this.increaseDamage(); //increase damage if any cocoons out of range
			return true;
		}
        
        private static method begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            integer i = 0;
            this.caster = caster;

            this.setup();
			
            this.transformCocoon();
            
			this.ticks = 0;
            this.tickTimer = GameTimer.newPeriodic(function(GameTimer t){
                thistype this = t.data();
				
				this.ticks = this.ticks + 1;
				// If false then something went wrong, destroy!
				if (this.duration < (TICK_DURATION * this.ticks) || !this.tick()) {
                    this.transformMinion();
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
            this.caster = null;
			this.totalCocoon = 0;
            DestroyGroup(this.groupCocoon);
            FlushParentHashtable(FossuriousUlt.hCocMin);
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            thistype.begin(caster);
        }
        
        public static method onAbilitySetup(){
            trigger t = CreateTrigger();
            unit uCocoon = null;
            GT_RegisterStartsEffectEvent(t, thistype.ABILITY_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            XE_PreloadAbility(thistype.ABILITY_ID);
			t = null;

            t = CreateTrigger();
            GT_RegisterUnitDiesEvent(t, thistype.COCOON_ID);
            TriggerAddCondition( t, Condition(function() -> boolean {
                uCocoon = GetTriggerUnit();
                FossuriousUlt.onCocoonDeath(uCocoon);

                thistype.totalCocoon = thistype.totalCocoon - 1;
                GroupRemoveUnit(thistype.groupCocoon, uCocoon);
                return false;
            }));
            t = null;
        }
	}
    
    private function onInit(){
        FossuriousUlt.onAbilitySetup.execute();
    }
}

//! endzinc