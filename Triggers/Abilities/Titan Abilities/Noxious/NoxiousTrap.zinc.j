//! zinc

library NoxiousTrap requires GT, GameTimer, xebasic, xepreload, xefx, IsUnitWard {
	private struct NoxiousTrap {
        integer abilityId = 'TOTR';
        integer dummyUnitId = 'o025';
        integer dummySlowId = 'A08Y';
        real damagePerSecond;
        real damageTotal;
        real damageDone = 0;
        real timerSpeed = .25;
        real time=0;
        integer poisonBuffId = 'B038';
        integer poisonRadius;
        integer dummyEyeAbility = 'A08X';
        boolean trapTriggered = false;
        unit caster;
        unit triggerUnit;
        real targetX;
        real targetY;
        real duration;
        damagetype damageType;
        static string groundEffect;
        static string builderEffect;
        string explosionEffect;
        //static string titanEffect;
        xefx poisonCloudDummy;
        xefx poisonCloudDummy2;
        xefx poisonDamageDummy;
        xecast dummyCaster;
        GameTimer periodicTimer;
        GameTimer durationTimer;
        effect groundSpecialEffect;
        effect loopingEffect;
        unit dummyUnit;
        
        private method Setup(integer level) {
            //How much damage per second should it do?
            this.damagePerSecond = (15 * level)/(1/this.timerSpeed);
            //How much damage total should it do if they stay in the area?
            this.damageTotal = 500;
            //The radius of the effect
            this.poisonRadius = 235;
            //The damage type of the ability
            this.damageType = DAMAGE_TYPE_MAGIC;
            //The duration of the ability
            this.duration = 900;
            //Poison damage/slow effect
            this.builderEffect = "Abilities\\Spells\\NightElf\\CorrosiveBreath\\ChimaeraAcidTargetArt.mdl";
            this.explosionEffect = "war3mapImported\\NecroticBlast.mdx";
            //this.titanEffect = "Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl";
        }
        
        private method DamageUnit(unit u) {
            effect e;
            e = AddSpecialEffectTarget(this.builderEffect, u, "origin");
            UnitDamageTarget(this.caster, u, this.damagePerSecond, false, false, ATTACK_TYPE_CHAOS, this.damageType, null);
            this.damageDone = this.damageDone + this.damagePerSecond;
            DestroyEffect(e);
        }
        
        private method CheckTarget(unit u) -> boolean {
            player p = GetOwningPlayer(this.caster); // Apparently player handles do not leak, so this is good!
            return IsUnitEnemy(u, p) && // Alliances
               !IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) &&                 // Magic
               !IsUnitType(u, UNIT_TYPE_STRUCTURE) &&                    // Organic only
               !IsUnitType(u, UNIT_TYPE_MECHANICAL) &&
               !IsUnitWard(u) &&                                         // No wards
                UnitAlive(u) &&
                (!(UnitManager.isMinion(u) || UnitManager.isTitan(u))) &&
                u != this.dummyUnit && GetUnitTypeId(u) != this.dummyUnitId;    // Is Alive
        }
        
        public method tick() {
            //Group T is to select the units around the trap, if they match then we set it up
            group t = CreateGroup();
            unit u = null;
            if(UnitAlive(this.dummyUnit)) {
                GroupEnumUnitsInRange(t, this.targetX, this.targetY, this.poisonRadius, null);
                u = FirstOfGroup(t);
                //If the first unit is equal to null there's no units
                while(u != null) {
                    if(this.CheckTarget(u)) {
                        if(!this.trapTriggered) {
                            this.trapTriggered = true;
                            this.dummyCaster = xecast.createBasicA(this.dummyEyeAbility, 852570, GetOwningPlayer(this.caster));
                            this.dummyCaster.castOnTarget(u);
                            this.groundSpecialEffect = AddSpecialEffect(this.explosionEffect, GetUnitX(u), GetUnitY(u));
                            UnitApplyTimedLife(this.dummyUnit, 'BTLF', 5);
                        }
                        this.DamageUnit(u);
                    }
                    GroupRemoveUnit(t, u);
                    u=null;
                    u = FirstOfGroup(t);
                }
            } else {
                RemoveUnit(this.dummyUnit);
                DestroyEffect(this.groundSpecialEffect);
                DestroyEffect(this.loopingEffect);
                this.dummyUnit = null;
                this.durationTimer.deleteLater();
                this.periodicTimer.deleteLater();
                this.destroy();
            }
            DestroyGroup(t);
            u=null;
            t=null;
        }
        
        private static method Begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            unit dummy;
            this.caster = caster;
            this.Setup(GetUnitAbilityLevel(this.caster, this.abilityId));
            this.targetX = GetSpellTargetX();
            this.targetY = GetSpellTargetY();
            this.dummyUnit = CreateUnit(GetOwningPlayer(this.caster), this.dummyUnitId, this.targetX, this.targetY, bj_UNIT_FACING);
            UnitAddAbility(this.dummyUnit, this.dummySlowId);
            //Start timer here to check for units
            //Start our two timers (one to check collision the other to end the current trap
            this.periodicTimer = GameTimer.newPeriodic(function(GameTimer t){
                thistype this = t.data();
                this.tick();
            }).start(this.timerSpeed);
            this.periodicTimer.setData(this);
            this.durationTimer = GameTimer.new(function(GameTimer t) {
                thistype this = t.data();
                this.durationTimer.deleteLater();
                this.periodicTimer.deleteLater();
                this.dummyUnit = null;
                this.destroy();
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