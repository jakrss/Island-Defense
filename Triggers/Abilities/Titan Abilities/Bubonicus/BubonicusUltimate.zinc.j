//! zinc

// TBAE
library BubonicusUltimate requires GT, xebasic, xepreload, xefx, Damage, AIDS {
    private struct MeatShield {
        public static real DEFAULT_HEALTH = 500.0;
        public static string MEAT_EFFECT = "Abilities\\Weapons\\MeatwagonMissile\\MeatwagonMissile.mdl";
        public static string TRAIL_EFFECT = "war3mapImported\\BloodySplat Missile.mdl";
        real hp = 0.0;
        xefx meat = 0;
        xefx trail = 0;
        BubonicusUltimate parent = 0;
        
        public static method create(BubonicusUltimate parent) -> thistype {
            thistype this = thistype.allocate();
            this.parent = parent;
            this.meat = xefx.create(0, 0, bj_UNIT_FACING);
            this.meat.fxpath = thistype.MEAT_EFFECT;
            this.meat.z = 100.0;
            this.trail = xefx.create(0, 0, bj_UNIT_FACING);
            this.trail.fxpath = thistype.TRAIL_EFFECT;
            this.trail.z = 20.0;
            
            this.setHealth(thistype.DEFAULT_HEALTH);
            
            return this;
        }
        
        public method onDestroy() {
            this.hp = 0.0;
            this.parent = 0;
            this.meat.destroy();
            this.trail.destroy();
            this.meat = 0;
            this.trail = 0;
        }
        
        public method setPosition(real x, real y) {
            this.meat.x = x;
            this.meat.y = y;
            this.trail.x = x;
            this.trail.y = y;
        }
        
        public method x() -> real {
            return this.meat.x;
        }
        
        public method y() -> real {
            return this.meat.y;
        }
        
        public method health() -> real {
            return this.hp;
        }
        
        public method setHealth(real health) {
            this.hp = health;
            this.meat.scale = (health / thistype.DEFAULT_HEALTH) + 0.5;
            this.trail.scale = health / thistype.DEFAULT_HEALTH;
        }
    }
    
    private struct BubonicusUltimate {
        private static constant integer ABILITY_ID = 'TBAF';
        private static constant integer BUFF_ID = 'B01B';
        private static constant integer WW_ID = 'B01C';
        private static constant integer MAX_SHIELDS = 6;
        
        private method setup(integer level){
            
        }
        private unit caster = null;
        private player castingPlayer = null;
        private MeatShield shields[thistype.MAX_SHIELDS];
        private integer shieldsCount = 0;
        private integer index = 0;
        private xedamage damage = 0;
        private GameTimer duration = 0;
        private boolean terminate = false;
        private real delta = 0.0;
        
        private static Table units = 0;
        public static method operator[] (unit u) -> thistype {
            integer id = GetUnitIndex(u);
            return thistype.units[id];
        }
        
        private method tick() {
            integer i = 0;
            real angle = 0.0;
            
            if (GetUnitAbilityLevel(this.caster, thistype.BUFF_ID) == 0 ||
                this.shieldsCount == 0 ||
                this.terminate) {
                // Lost buff, destroy!
                this.duration.deleteNow();
                this.duration.deleteLater();
                this.duration = 0;
                this.destroy();
                return;
            }
            
            // Move shields
            this.delta = this.delta + 6.0;
            if (this.delta > 360.0) {
                this.delta = this.delta - 360.0;
            }
            
            for (0 <= i < this.shieldsCount) {
                angle = (i * (360.0 / this.shieldsCount)) + this.delta;
                if (angle > 360.0) {
                    angle = angle - 360.0;
                }
                
                this.shields[i].setPosition(GetUnitX(this.caster) + 150.0 * Cos(angle * bj_DEGTORAD),
                                            GetUnitY(this.caster) + 150.0 * Sin(angle * bj_DEGTORAD));
            }
        }
        
        private method shieldDeath(MeatShield u) {
            integer i = 0;
            
            // Sort out ordering of shields
            for (0 <= i < this.shieldsCount) {
                if (this.shields[i] == u) {
                    if (i == this.shieldsCount - 1) {
                        this.shields[i] = 0;
                        this.shieldsCount = this.shieldsCount - 1;
                    }
                    else {
                        // We have to swap!
                        this.shields[i] = this.shields[this.shieldsCount - 1];
                        this.shields[this.shieldsCount - 1] = 0;
                        this.shieldsCount = this.shieldsCount - 1;
                    }
                }
            }
            
            // Gas Cloud
            UnitApplyTimedLife(CreateUnit(this.castingPlayer, 'u007', u.x(), u.y(), 270.0), 'BTLF', 5.0);
            
            // Kill
            u.destroy();
            
            // Remove buff if no more shields
            if (this.shieldsCount == 0) {
                UnitRemoveAbility(this.caster, thistype.BUFF_ID);
            }
        }
        
        private method damageShields(unit u, real damage, damagetype t) {
            MeatShield shield = 0;
            if (this.shieldsCount > 0) {
                shield = this.shields[GetRandomInt(0, this.shieldsCount - 1)];
            
                this.damage.dtype = t;
                damage = this.damage.getTargetFactor(u, this.caster) * damage;
                if (shield.health() - damage < 0.405) {
                    this.shieldDeath(shield);
                }
                else {
                    shield.setHealth(shield.health() - damage);
                }
            }
        }
        
        private method addShield() {
            MeatShield shield = MeatShield.create(this);
            
            this.shields[this.shieldsCount] = shield;
            this.shieldsCount = this.shieldsCount + 1;
        }
        
        private static method begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            integer id = GetUnitIndex(caster);
            this.caster = caster;
            this.castingPlayer = GetOwningPlayer(this.caster);
            this.duration = 0;
            this.damage = xedamage.create();
            this.terminate = false;
            this.delta = 0.0;
            
            this.index = id;
            if (thistype[caster] != 0) {
                // Destroy extra on next spin
                // It shouldn't mess up since from now on every reference to thistype.units[id] will be our new instance?
                thistype[caster].terminate = true;
            }
            thistype.units[id] = this;
            
            while (Bubonicus[this.caster].count() > 0) {
                Bubonicus[this.caster].subtract();
                this.addShield();
            }
            
            if (this.shieldsCount == 0) {
                // The tick will handle removing the buff a little later!
                Bubonicus[this.caster].error("|cffff0000Your ultimate ability requires at least one corpse.|r");
                this.terminate = true;
            }
            
            this.duration = GameTimer.newPeriodic(function(GameTimer t) {
                thistype this = t.data();
                if (this != 0) {
                    this.tick();
                }
            });
            // Don't bother starting to proper timer if we're just going to terminate it anyway
            if (!this.terminate) {
                this.duration.setData(this);
                this.duration.start(0.03125);
            }
            
            // Start immediately!
            GameTimer.new(function(GameTimer t) {
                thistype this = t.data();
                if (this != 0) {
                    if (this.terminate) {
                        UnitRemoveAbility(this.caster, thistype.BUFF_ID);
                    }
                    this.tick();
                }
            }).start(0.0).setData(this);
            
            return this;
        }
        
        private method onDestroy(){
            integer i = 0;
            
            // Check to make sure the currently stored index is our own.
            if (thistype.units[this.index] == this) {
                thistype.units.remove(this.index);
            }
            
            if (this.duration != 0) {
                this.duration.deleteNow();
            }
            for (0 <= i < this.shieldsCount) {
                this.shields[i].destroy();
                this.shields[i] = 0;
            }
            this.shieldsCount = 0;
            this.index = 0;
            this.caster = null;
            this.castingPlayer = null;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            thistype.begin(caster);
        }
        
        private static method onDamage() {
            thistype this = thistype[GetTriggerUnit()];
            if (this != 0 && this.shieldsCount > 0) {
                if (GetEventDamageSource() != GetTriggerUnit() && // Allow Bubonicus to damage himself
                    GetEventDamage() > 0) { // And allow heals
                    Damage_BlockAll();
                    this.damageShields(GetEventDamageSource(), GetEventDamage(),Damage_GetType()); 
                }
            }
        }
        
        public static method onSetup(){
            trigger t = CreateTrigger();
            GT_RegisterStartsEffectEvent(t, thistype.ABILITY_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            t = CreateTrigger();
            Damage_RegisterEvent(t);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onDamage();
                return false;
            }));
            t = null;
            XE_PreloadAbility(thistype.ABILITY_ID);
            thistype.units = Table.create();
        }
    }
    
    private function onInit(){
        BubonicusUltimate.onSetup.execute();
    }
}


//! endzinc