//! zinc

library NoxiousHeal requires GT, GameTimer, xebasic, xepreload, xefx, IsUnitWard, xedamage, Healing {
	private struct NoxiousHeal {
        static integer abilityId = 'TSAE';
        static integer miniAbilityId = 'A08Z';
        xedamage heal;
        real healAmountInstant;
        real miniHealAmountInstant;
        real periodicHealAmount;
        real timerSpeed = .25;
        integer healRadius;
        unit caster;
        real casterX;
        real casterY;
        real duration;
        string healEffect;
        string healPeriodicEffect;
        //static string titanEffect;
        unit dummyUnit;
        GameTimer durationTimer;
        GameTimer periodicTimer;
        
        private method Setup(integer level) {
            //How much health total should it heal
            this.healAmountInstant = 125+(50*level);
            //How much health total should the minis heal
            this.miniHealAmountInstant = 50+(50*level)*.70;
            //The radius of the effect
            this.healRadius = 800;
            //The duration of the ability
            this.duration = 5;
            //Heal per second
            this.periodicHealAmount = (10+(20 * level))*this.timerSpeed;
            //Heal effect and the heal effect per instant
            this.healEffect = "war3mapImported\\NoxiousHealCloud.mdl";
            this.healPeriodicEffect = "war3mapImported\\Noxious'HealSparkle.mdl";
        }
        
        private static method damageFactor() -> real {
            return 1.33;
        }
        
        private method HealUnits(boolean periodic) {
            group g = CreateGroup();
            unit u=null;
            effect e;
            GroupEnumUnitsInRange(g, this.casterX, this.casterY, this.healRadius, null);
            u=FirstOfGroup(g);
            while(u!=null) {
                if((UnitManager.isTitan(u) || UnitManager.isMinion(u))) {
                    if(periodic) {
                        this.heal = xedamage.create();
                        this.heal.damageSelf = true;
                        this.heal.damageAllies = true;
                        this.heal.damageEnemies = false;
                        this.heal.damageNeutral = false;
                        this.heal.allyfactor = -1.0;
                
                        this.heal.damageTarget(this.caster, u, this.periodicHealAmount * this.damageFactor());
                        e = AddSpecialEffectTarget(this.healPeriodicEffect, u, "origin");
                        DestroyEffect(e);
                        this.heal.destroy();
                    } else if (!periodic) {
                        this.heal = xedamage.create();
                        this.heal.damageSelf = true;
                        this.heal.damageAllies = true;
                        this.heal.damageEnemies = false;
                        this.heal.damageNeutral = false;
                        this.heal.allyfactor = -1.0;
                
                        this.heal.damageTarget(this.caster, u, this.healAmountInstant * this.damageFactor());
                        e = AddSpecialEffectTarget(this.healEffect, u, "origin");
                        DestroyEffect(e);
                        this.heal.destroy();
                    }
                }
                GroupRemoveUnit(g, u);
                u=null;
                u=FirstOfGroup(g);
            }
            DestroyGroup(g);
            u=null;
        }
        
        private static method Begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.Setup(GetUnitAbilityLevel(this.caster, GetSpellAbilityId()));
            this.casterX = GetUnitX(this.caster);
            this.casterY = GetUnitY(this.caster);
            this.healAmountInstant = this.healAmountInstant + getInsightBonus(this.caster);
            this.HealUnits(false);
            //Start timer here to end the spell and cleanup
            this.periodicTimer = GameTimer.newPeriodic(function(GameTimer t) {
                thistype this = t.data();
                this.HealUnits(true);
            }).start(this.timerSpeed);
            this.periodicTimer.setData(this);
            this.durationTimer = GameTimer.new(function(GameTimer t) {
                thistype this = t.data();
                this.periodicTimer.deleteLater();
                this.durationTimer.deleteLater();
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
            GT_RegisterStartsEffectEvent(t, thistype.miniAbilityId);
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