//! zinc

// TLAF
library NoxiousUltimate requires GT, xebasic, xepreload, Table, AIDS, IsUnitWall, xemissile, xefx {
    private struct NoxiousUltimate {
        private static constant integer ABILITY_ID = 'A092';
        private static constant string TARGET_EFFECT = "Abilities\\Weapons\\PoisonSting\\PoisonStingTarget.mdl";
        private static constant string MISSILE_EFFECT = "Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdl";
        private static constant integer DURATION = 20;
        private static constant real TIMER_INTERVAL = .4;
        private static constant real DMG_PER_SECOND = 25;
        private static constant real DAMAGE_AREA = 325;
        
        private unit caster = null;
        private player castingPlayer = null;
        private GameTimer tickTimer;
        private GameTimer durationTimer;
        private GameTimer poisonTimer;
        private xedamage damage = 0;
        private integer dummyId = 'o028';
        //How long the poison lasts on the ground
        private integer poisonDuration = 5;
        //How often we create a poison dummy
        private integer poisonInterval = 1;
        private group dummyGroup = CreateGroup();
        private xehomingmissile dummyMissile;
        
        public method checkTarget(unit u) -> boolean {
            return (!IsUnitAlly(u, this.castingPlayer) ||
                    GetOwningPlayer(u) == Player(PLAYER_NEUTRAL_PASSIVE)) &&
                    UnitAlive(u) && (IsUnitWall(u) || !(IsUnitType(u, UNIT_TYPE_STRUCTURE)));
        }
        
        private method tick(){
            group g = CreateGroup();
            unit u = null;
            real x = GetUnitX(this.caster);
            real y = GetUnitY(this.caster);
            
            // Windwalked or mirrored
            if (GetUnitAbilityLevel(this.caster, 'B006') > 0 || GetUnitAbilityLevel(this.caster, 'BHbn') > 0) {
                // Ignore this tick, as we are windwalked
            }
            else {
                GroupEnumUnitsInRange(g, x, y, this.DAMAGE_AREA, null);
                
                u = FirstOfGroup(g);
                while (u != null){
                    if (this.checkTarget(u)){
                        this.dummyMissile = xehomingmissile.create(x, y, 100, u, 20);
                        this.dummyMissile.fxpath = MISSILE_EFFECT;
                        this.dummyMissile.launch(1000, .1);
                        this.damage.damageTarget(this.caster, u, thistype.DMG_PER_SECOND * thistype.TIMER_INTERVAL);
                    }
                    GroupRemoveUnit(g, u);
                    u = FirstOfGroup(g);
                }
            }
            
            GroupClear(g);
            DestroyGroup(g);
            g = null;
            u = null;
        }
        
        private method poisonUnits(real x, real y) {
            unit u;
            u=CreateUnit(GetOwningPlayer(this.caster), this.dummyId, x, y, bj_UNIT_FACING);
            UnitApplyTimedLife(u, 'BTLF', this.poisonDuration);
            u = null;
            u=null;
        }
        
        private static method begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.castingPlayer = GetOwningPlayer(this.caster);
            
            this.damage = xedamage.create();
            this.damage.dtype = DAMAGE_TYPE_MAGIC;
            this.damage.required = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(thistype.TARGET_EFFECT, "head");
            this.damage.forceEffect = true;
            this.tickTimer = GameTimer.newPeriodic(function(GameTimer t){
                thistype this = t.data();
                if (this.caster != null
                    && UnitAlive(this.caster)) {
                    this.tick();
                }
            }).start(this.TIMER_INTERVAL);
            this.tickTimer.setData(this);
            this.poisonTimer = GameTimer.newPeriodic(function(GameTimer t){
                thistype this = t.data();
                if (this.caster != null
                    && UnitAlive(this.caster)) {
                    this.poisonUnits(GetUnitX(this.caster), GetUnitY(this.caster));
                }
            }).start(this.poisonInterval);
            this.poisonTimer.setData(this);
            this.durationTimer = GameTimer.new(function(GameTimer t){
                thistype this = t.data();
                DestroyGroup(this.dummyGroup);
                this.destroy();
            }).start(this.DURATION);
            this.durationTimer.setData(this);
            
            return this;
        }
        
        private method onDestroy(){
            this.caster = null;
            this.castingPlayer = null;
            if (this.tickTimer != 0) {
                this.tickTimer.deleteNow();
                this.tickTimer = 0;
            }
            this.damage.destroy();
            this.damage = 0;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            thistype.begin(caster);
        }
        
        public static method onSetup(){
            trigger t = CreateTrigger();
            GT_RegisterStartsEffectEvent(t, thistype.ABILITY_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            
            t = null;
            XE_PreloadAbility(thistype.ABILITY_ID);
        }
    }
    
    private function onInit(){
        NoxiousUltimate.onSetup.execute();
    }
}


//! endzinc