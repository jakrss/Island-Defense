//! zinc

library Bubonicus requires GameTimer, GT, Table, Transport {
    private struct BubonicusDiseaseCloud {
        public static constant real DISEASE_DAMAGE_CORPSE_FACTOR = 1.0;
        public static constant real DISEASE_DAMAGE_PER_SECOND = 4.0;
        public static constant real DISEASE_DAMAGE_TICK = 1.0;
        public static constant integer DISEASE_TOTAL_TICKS = 5;
        private static Table units = 0;
        private integer ticks = 0;
        private real amount = 0;
        private xedamage damage = 0;
        private unit cause = null;
        private unit afflicted = null;
        private GameTimer tickTimer = 0;
        private integer index = 0;
        private effect diseasedEffect = null;
        
        public static method checkTarget(unit u, unit cause) -> boolean {
            return (!IsUnitAlly(u, GetOwningPlayer(cause)) ||
                    GetOwningPlayer(u) == Player(PLAYER_NEUTRAL_PASSIVE)) &&
                   !IsUnitType(u, UNIT_TYPE_STRUCTURE) &&
                   !IsUnitType(u, UNIT_TYPE_MECHANICAL) &&
                    UnitAlive(u); 
                                    //Check for Wind Walk so we don't damage target
        }
        
        public method tick() {
            this.ticks = this.ticks - 1;
            if (this.ticks <= 0 || this.afflicted == null ||
                !UnitAlive(this.afflicted) || !thistype.checkTarget(this.afflicted, this.cause)) {
                this.destroy();
                return;
            }
            if(GetUnitAbilityLevel(this.cause, 'B01C') == 0) {
                this.damage.damageTarget(this.cause, this.afflicted, this.amount);
            }
        }
        
        public method onDestroy() {
            if (this.tickTimer != 0) {
                this.tickTimer.deleteLater();
                this.tickTimer = 0;
            }
            DestroyEffect(this.diseasedEffect);
            this.diseasedEffect = null;
            this.damage.destroy();
            this.afflicted = null;
            this.cause = null;
            
            thistype.units.remove(this.index);
        }
        
        public static method begin(unit u, unit cause, integer corpses) -> thistype {
            thistype this = 0;
            integer id = 0;
            
            if (corpses == 0 || !thistype.checkTarget(u, cause)) return 0;
            id = GetUnitIndex(u);
            if (thistype.units == 0) {
                thistype.units = Table.create();
            }
            if (thistype.units.has(id)) {
                // Already has a value, reset timer
                this = thistype.units[id];
                this.ticks = thistype.DISEASE_TOTAL_TICKS;
            }
            else {
                this = thistype.allocate();
                this.damage = xedamage.create();
                this.damage.dtype = DAMAGE_TYPE_DISEASE; // Physical, ignores Armor
                this.amount = thistype.DISEASE_DAMAGE_PER_SECOND * 
                              (corpses * thistype.DISEASE_DAMAGE_CORPSE_FACTOR) * 
                              thistype.DISEASE_DAMAGE_TICK;
                this.afflicted = u;
                this.cause = cause;
                this.tickTimer = GameTimer.newPeriodic(function(GameTimer t){
                    thistype this = t.data();
                    if (this != 0) {
                        this.tick();
                    }
                });
                this.tickTimer.setData(this);
                this.tickTimer.start(thistype.DISEASE_DAMAGE_TICK);
                this.diseasedEffect = AddSpecialEffectTarget("Units\\Undead\\PlagueCloud\\PlagueCloudtarget.mdl", u, "head");
                this.index = id;
                thistype.units[id] = this;
                
                // Force first tick now
                this.ticks = thistype.DISEASE_TOTAL_TICKS;
                this.tick();
            }
            
            
            return this;
        }
    }
    
    private struct BubonicusWard {
        public Bubonicus main = 0;
        public unit ward = null;
        
        public static method create(unit u, Bubonicus m) -> thistype {
            thistype this = thistype.allocate();
            real time = 40.0;
            this.ward = u;
            this.main = m;
            
            // dirty fix
            if (this.main.max() == 6) {
                time = 30;
            }
            
            GameTimer.new(function(GameTimer t) {
                thistype this = t.data();
                if (UnitAlive(this.ward)) {
                    UnitAddAbility(this.ward, 'A04B');
                    // dirty fix
                    if (this.main.max() == 6) {
                        SetUnitAbilityLevel(this.ward, 'A04B', 2);
                    }
                }
            }).start(time).setData(this);
            
            return this;
        }
    }
    
    public struct Bubonicus {
        private static Table units = 0;
        integer corpseCount = 0;
        unit main = null;
        integer index = 0;
        effect diseasedEffect = null;
        integer exhumeLevel = 0;
		integer show = 1;
        public method max() -> integer {
            if (this.exhumeLevel >= 1) {
                return 6;
            }
            return 4;
        }
        
        public method tick() {
            group g=null;
            unit u=null;
            if(GetUnitAbilityLevel(this.main, 'B01C') == 0) {
                g = CreateGroup();
                u = null;
                
                GroupEnumUnitsInRange(g, GetUnitX(this.main), GetUnitY(this.main), 250.0, null);
                
                u = FirstOfGroup(g);
                while (u != null) {
                    BubonicusDiseaseCloud.begin(u, this.main, this.count());
                    GroupRemoveUnit(g, u);
                    u = FirstOfGroup(g);
                }
                
                DestroyGroup(g);
                g = null;
                u = null;
            }
        }

        public static method diseaseTick() {
            group g = CreateGroup();
            unit u = null;
            boolexpr b = Filter(function() -> boolean {
                return Bubonicus.has(GetFilterUnit());
            });
            
            GroupEnumUnitsInRect(g, GetWorldBounds(), b);
            
            u = FirstOfGroup(g);
            while (u != null) {
                // Found a Bubonicus
                thistype[u].tick();
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            
            DestroyBoolExpr(b);
            DestroyGroup(g);
            b = null;
            g = null;
            u = null;
        }
        
        public method count() -> integer {
            return corpseCount;
        }
        
        public method checkCount() {
            if (this.count() >= this.max()) {
                SetUnitAbilityLevel(this.main, 'TBAD', 2);
            }
            else {
                SetUnitAbilityLevel(this.main, 'TBAD', 1);
            }
        }
        
        public static method operator[] (unit u) -> thistype {
            thistype this = 0;
            integer i = GetUnitIndex(u);
            if (!thistype.units.has(i)) {
                this = thistype.allocate();
                this.main = u;
                this.exhumeLevel = 0;
                this.index = i;
                thistype.units[i] = this;
            }
            else {
                this = thistype.units[i];
            }
            return this;
        }
        
        public static method has(unit u) -> boolean {
            integer i = GetUnitIndex(u);
            return thistype.units.has(i) && thistype.units[i] != 0;
        }
        
        public method onDestroy() {
            this.main = null;
            while (this.corpseCount > 0) {
                this.subtract();
            }
            thistype.units.remove(this.index);
        }
        
        public method onAdd(unit u) {
            RemoveUnit(u);
            
            UnitRemoveAbility(this.main, 'TBA0' + this.corpseCount);
            this.corpseCount = this.corpseCount + 1;
            UnitAddAbility(this.main, 'TBA0' + this.corpseCount);
            
            this.checkCount();
            
            this.onAddEffect.execute();
        }
        
        public method subtract() {
            if (this.corpseCount == 0) return;
            this.corpseCount = this.corpseCount - 1;
            
            this.onSubtractEffect.execute();
        }
        
        public method onDrop() {
            if (this.corpseCount == 0) {
                return;
            }
            
            this.corpseCount = this.corpseCount - 1;
            this.onDropEffect.execute();
        }
        
        private method onAddEffect() {
            // Disease Cloud
            if (this.count() > 0 && this.diseasedEffect == null) {
                this.diseasedEffect = AddSpecialEffectTarget("units\\undead\\PlagueCloud\\PlagueCloud.mdl", this.main, "origin");
				if(this.count() == 1 && this.show == 0) {
					BlzUnitDisableAbility(this.main, 'ANhs', false, false);
					BlzUnitDisableAbility(this.main, 'TBAF', false, false);
					this.show = 1;
					//BJDebugMsg("Enabling now");
				}
            }
            if (this.exhumeLevel >= 2) {
				if (GetUnitAbilityLevel(this.main, 'A045') == 0) {
                    UnitAddAbility(this.main, 'A045');
                }
                SetUnitAbilityLevel(this.main, 'A045', this.count());
            }
        }
        
        private method onRemoved() {
            UnitRemoveAbility(this.main, 'TBA0' + this.corpseCount + 1);
            UnitAddAbility(this.main, 'TBA0' + this.corpseCount);
            this.checkCount();
			if(this.count() <= 0) {
				DestroyEffect(this.diseasedEffect);
                this.diseasedEffect = null;
				if(this.exhumeLevel >= 2) {
					UnitRemoveAbility(this.main, 'A045');
				}
				if(this.count() == 0 && this.show == 1) {
					BlzUnitDisableAbility(this.main, 'ANhs', true, false);
					BlzUnitDisableAbility(this.main, 'TBAF', true, false);
					this.show = 0;
					//BJDebugMsg("Should disable now");
				}
			} else {
				if(this.exhumeLevel >= 2) {
					SetUnitAbilityLevel(this.main, 'A045', this.count());
				}
			}
        }

         public method disableAbility(integer abilityid) {
            this.checkCount();
			if(this.count() <= 0) {
				if(this.count() == 0) {
					BlzUnitDisableAbility(this.main, abilityid, true, false);
					//BJDebugMsg("Should disable now");
				}
			}
        }
       	
        
        private method onSubtractEffect() {
            this.onRemoved();
        }	

        public method learnExhume(integer i) {
			if (i == 1) {
				this.exhumeLevel = 1;
				return;
			}
			activateExhume2();
		}
		public method activateExhume2() {
            group g = CreateGroup();
            unit u = null;
            
			this.exhumeLevel = 2;
            this.checkCount();
            SetUnitAbilityLevel(UnitManager.TITAN_SPELL_WELL, 'A044', 2); // Upgrade mound spawn time
			
			// Add armor
			if (this.count() > 0) {
				if (GetUnitAbilityLevel(this.main, 'A045') == 0) {
                    UnitAddAbility(this.main, 'A045');
                }
                SetUnitAbilityLevel(this.main, 'A045', this.count());
			}
            
            // All wards
            GroupEnumUnitsInRect(g, GetWorldBounds(), Filter(function() -> boolean {
                return GetUnitAbilityLevel(GetFilterUnit(), 'A04B') == 1;
            }));
            
            u = FirstOfGroup(g);
            while (u != null) {
                SetUnitAbilityLevel(u, 'A04B', 2); // Upgrade
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            
            GroupClear(g);
            DestroyGroup(g);
            g = null;
            u = null;
        }
        
        public method unlearnExhume() {
            group g = null;
            unit u = null;
            
            if (this.exhumeLevel == 0) return;
            
            g = CreateGroup();
            this.exhumeLevel = 0;
            this.checkCount();
            SetUnitAbilityLevel(UnitManager.TITAN_SPELL_WELL, 'A044', 1); // Downgrade mound spawn time
            
            // All wards
            GroupEnumUnitsInRect(g, GetWorldBounds(), Filter(function() -> boolean {
                return GetUnitAbilityLevel(GetFilterUnit(), 'A04B') == 2;
            }));
            
            u = FirstOfGroup(g);
            while (u != null) {
                SetUnitAbilityLevel(u, 'A04B', 1); // Downgrade
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            
            GroupClear(g);
            DestroyGroup(g);
            g = null;
            u = null;
        }
        
        public method error(string s) {
            player p = GetOwningPlayer(this.main);
            PlayerData q = PlayerData.get(p);
            if (q == 0) return;
            q.say(s);
        }
        
        private method onDropEffect() {
            real x = GetUnitX(this.main);
            real y = GetUnitY(this.main);
            unit v = null;
            
            // This restricts where corpse wards can spawn
            if (IsTerrainDeepWater(x, y)) {
                this.error("|cffff0000You may not spawn Corpse Wards on water.|r");
            } else {
                v = CreateUnit(GetOwningPlayer(this.main), 'u008', x, y, bj_UNIT_FACING);
                UnitApplyTimedLife(v, 'BTLF', 300.0); // 5 minutes
                
                BubonicusWard.create(v, this);
                
                this.onRemoved();
                return;
            }
            
            CreateCorpse(GetOwningPlayer(this.main), 'u00A', x, y, bj_UNIT_FACING);
            this.onRemoved();
        }
        
        public static method onWardDeath(unit u) {
            RemoveUnit(u);
            u = null;
        }
        
        public static method setup() {
            thistype.units = Table.create();
        }
    }
    
    private function onInit(){
        trigger t = null;
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SUMMON, function() -> boolean {
            unit u = GetSummoningUnit();
            unit v = GetSummonedUnit();
            if (!Bubonicus.has(u) ||
                GetUnitTypeId(v) != 'u00A') return false;
            Bubonicus[u].onAdd(v);
            u = null;
            v = null;
            return false;
        });
        
        t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'TBA1');
        GT_RegisterStartsEffectEvent(t, 'TBA2');
        GT_RegisterStartsEffectEvent(t, 'TBA3');
        GT_RegisterStartsEffectEvent(t, 'TBA4');
        GT_RegisterStartsEffectEvent(t, 'TBA5');
        GT_RegisterStartsEffectEvent(t, 'TBA6');
        TriggerAddCondition(t, Condition(function() -> boolean {
            return Bubonicus.has(GetTriggerUnit());
        }));
        TriggerAddAction(t, function() {
            unit u = GetTriggerUnit();
            Bubonicus b = Bubonicus[u];
            GameTimer.new(function(GameTimer t) {
                Bubonicus b = t.data();
                b.onDrop();
            }).start(0.0).setData(b);
            u = null;
        });
        t = CreateTrigger();
        TriggerRegisterTimerEvent(t, BubonicusDiseaseCloud.DISEASE_DAMAGE_TICK / 2.0, true);
        TriggerAddCondition(t, Condition(function() -> boolean {
            Bubonicus.diseaseTick();
            return false;
        }));
        t = CreateTrigger();
        GT_RegisterLearnsAbilityEvent(t, 'TBAR');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetLearningUnit();
			integer i = GetLearnedSkillLevel();
            if (!Bubonicus.has(u)) return false;
            Bubonicus[u].learnExhume(i);
            u = null;
            return false;
        }));
        t = CreateTrigger();
        GT_RegisterLearnsAbilityEvent(t, 'ANhs'); //Nuke
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetLearningUnit();
            integer i = GetLearnedSkillLevel();
            integer a = 'ANhs';
            if (!Bubonicus.has(u)) return false;
            if (i == 1) Bubonicus[u].disableAbility(a);
            u = null;
            return false;
        }));
        t = CreateTrigger();
        GT_RegisterLearnsAbilityEvent(t, 'TBAF'); //Ult
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetLearningUnit();
            integer i = GetLearnedSkillLevel();
            integer a = 'TBAF';
            if (!Bubonicus.has(u)) return false;
            if (i == 1) Bubonicus[u].disableAbility(a);
            u = null;
            return false;
        }));
        t = CreateTrigger();
        GT_RegisterUnitDiesEvent(t, 'u008');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetDyingUnit();
            Bubonicus.onWardDeath(u);
            u = null;
            return false;
        }));
        
        // Tome of Retraining check
        t = CreateTrigger();
        GT_RegisterItemUsedEvent(t, 'I05S');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            if (!Bubonicus.has(u)) return false;
            Bubonicus[u].unlearnExhume();
            u = null;
            return false;
        }));
        t = null;
        
        Bubonicus.setup.execute();
    }
}


//! endzinc