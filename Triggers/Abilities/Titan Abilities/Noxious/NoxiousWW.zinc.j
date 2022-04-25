//! zinc

library NoxiousWW requires GT, GameTimer, xebasic, xepreload, xefx, IsUnitWard, xecast {
	private struct NoxiousWW {
        integer abilityId = 'TSAW';
        integer dummySlowAbilityId = 'A08S';
        integer dummyUnitId = 'e01B';
        real damagePerSecond;
        real timerSpeed = .25;
        integer poisonBuffId = 'B038';
        integer poisonRadius;
        unit caster;
        unit triggerUnit;
        real casterX;
        real casterY;
        real duration;
        boolean dummyCreated;
        boolean spellEnded = false;
        damagetype damageType;
        static string groundEffect;
        static string builderEffect;
        //static string titanEffect;
        xefx poisonCloudDummy;
        xefx poisonDamageDummy;
        unit dummyUnit;
        GameTimer periodicTimer;
        GameTimer durationTimer;
        effect groundSpecialEffect;
        
        private method Setup(integer level) {
            //How much damage per second should it do?
            this.damagePerSecond = (4+ (5))/(1/this.timerSpeed);
            //The radius of the effect
            this.poisonRadius = 500;
            //The damage type of the ability
            this.damageType = DAMAGE_TYPE_MAGIC;
            //The duration of the gas cloud
            this.duration = 10;
            //Poison cloud effect
            this.groundEffect = "war3mapImported\\GreenCloudOfFog.mdx";
            //Poison damage/slow effect
            this.builderEffect = "war3mapImported\\DebuffPoisoned.mdx";
            //this.titanEffect = "war3mapImported\\DebuffPoisoned.mdx";
        }
        
        private method DamageUnit(unit u) {
            effect e = AddSpecialEffectTarget(this.builderEffect, u, "origin");
            if(GetWidgetLife(u) > this.damagePerSecond) {
                UnitDamageTarget(this.caster, u, this.damagePerSecond, false, false, ATTACK_TYPE_CHAOS, this.damageType, null);
            }
            DestroyEffect(e);
        }
        
        private method CheckTarget(unit u) -> boolean {
            player p = GetOwningPlayer(this.caster); // Apparently player handles do not leak, so this is good!
            return (IsUnitEnemy(u, p) ||
                GetOwningPlayer(u) == Player(PLAYER_NEUTRAL_PASSIVE)) && // Alliances
               !IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) &&                 // Magic
               !IsUnitType(u, UNIT_TYPE_STRUCTURE) &&                    // Organic only
               !IsUnitType(u, UNIT_TYPE_MECHANICAL) &&
               !IsUnitWard(u) &&                                         // No wards
                UnitAlive(u);                                         // Is Alive
        }
        
        public method tick() {
            group g = CreateGroup();
            unit u = null;
            effect e;
            GroupEnumUnitsInRange(g, this.casterX, this.casterY, this.poisonRadius, null);
            u = FirstOfGroup(g);
            //If the first unit is equal to null there's no units
            while(u != null) {
                if(this.CheckTarget(u) && IsUnitInGroup(u, g)) {
                    if(!this.dummyCreated) {
                        this.dummyUnit = CreateUnit(GetOwningPlayer(this.caster), this.dummyUnitId, this.casterX, this.casterY, bj_UNIT_FACING);
                        UnitAddAbility(this.dummyUnit, this.dummySlowAbilityId);
                        SetUnitAbilityLevel(this.dummyUnit, this.dummySlowAbilityId, 1);
                        UnitApplyTimedLife(this.dummyUnit, 'BTLF', this.duration);
                        this.dummyCreated = true;
                        this.DamageUnit(u);
                    } else {
                        this.DamageUnit(u);
                    }
                } else if(this.CheckTarget(u) && !IsUnitInGroup(u, g)) {
                    UnitRemoveAbility(u, this.poisonBuffId);
                }
                GroupRemoveUnit(g, u);
                u=null;
                u = FirstOfGroup(g);
            }
            DestroyGroup(g);
            u=null;
            g=null;
        }
        
             
        private static method Begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.Setup(GetUnitLevel(this.caster));
            this.casterX = GetUnitX(this.caster);
            this.casterY = GetUnitY(this.caster);
            this.poisonCloudDummy = xefx.create(this.casterX, this.casterY, GetUnitFacing(this.caster) * bj_DEGTORAD);
            this.poisonCloudDummy.fxpath = this.groundEffect;
            this.poisonCloudDummy.x = this.casterX;
            this.poisonCloudDummy.y = this.casterY;
            this.poisonCloudDummy.z = 10;
            this.poisonCloudDummy.scale = .7;
            //Start our two timers (one to check collision the other to end the current poison cloud
            this.periodicTimer = GameTimer.newPeriodic(function(GameTimer t){
                thistype this = t.data();
                this.tick();
            }).start(this.timerSpeed);
            this.periodicTimer.setData(this);
            this.durationTimer = GameTimer.new(function(GameTimer t) {
                thistype this = t.data();
                //Temporary group and unit meant to clear all units of the poison debuff should they have been affected
                group g=null;
                unit u=null;
                this.periodicTimer.deleteLater();
                //On end of duration we terminate all buffs that are active
                g=CreateGroup();
                GroupEnumUnitsInRect(g, bj_mapInitialPlayableArea, null);
                u=FirstOfGroup(g);
                while(u!=null) {
                    //If any defenders have the buff we remove it
                    if(GetUnitAbilityLevel(u, this.poisonBuffId) > 0) {
                        UnitRemoveAbility(u, this.poisonBuffId);
                    }
                    GroupRemoveUnit(g, u);
                    u=null;
                    u=FirstOfGroup(g);
                }
                DestroyGroup(g);
                u=null;
                g=null;
                this.dummyUnit = null;
                this.durationTimer.deleteLater();
                this.poisonCloudDummy.destroy();
            }).start(this.duration);
            this.durationTimer.setData(this);
            return this;
        }
        
        private static method onCast() {
            unit caster = GetSpellAbilityUnit();
            thistype.Begin(caster);
        }
        
        
        private static method onAbilitySetup(){
            trigger t = CreateTrigger();
            thistype this = thistype.allocate();
            integer id = this.abilityId;
            this.destroy();
            GT_RegisterStartsEffectEvent(t, id);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            XE_PreloadAbility(id);
        }
        
        private static method onInit() {
            thistype.onAbilitySetup();
        }
    }
}


//! endzinc