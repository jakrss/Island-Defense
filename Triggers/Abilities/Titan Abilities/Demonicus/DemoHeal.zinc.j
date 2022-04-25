//! zinc
library DemoHeal requires GT, GameTimer, xebasic, xepreload, xemissile, xefx, xedamage, Healing {
    private struct DemoHeal {
        private static constant string missileEffect = "Abilities\\Weapons\\SludgeMissile\\SludgeMissile.mdl";
        private static constant string healAreaEffect = "Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl";
        private static constant integer abilityId = 'TDAE';
        private unit caster;
        private real casterX;
        private real casterY;
        private real healPerSecond;
        private real duration;
        private real timerInterval = .5;
        private real radius;
        private GameTimer periodicTimer;
        private GameTimer durationTimer;
        private xefx aoeDummy;
        private xehomingmissile missileDummy;
        private xedamage heal;
        
        private method setup(integer level) {
            //How long should the effect last?
            this.duration = 2.0 + (.5 * level);
            //How much health should the ability heal per second?
                //If it's a mini it heals 70% as much
            if(GetUnitTypeId(this.caster) == 'U005') {
                this.healPerSecond = ((50+(50*level))* timerInterval)*.70;
            } else {
                this.healPerSecond = (50+(50*level))* timerInterval;
            }
            //How wide is the AOE?
            this.radius = 300 + (level * 100);
        }
        
        private method HealUnit(unit u) {
            this.heal = xedamage.create();
            this.heal.damageSelf = true;
            this.heal.damageAllies = true;
            this.heal.damageEnemies = false;
            this.heal.damageNeutral = false;
            this.heal.allyfactor = -1.0;
            this.healPerSecond = this.healPerSecond;
            this.heal.damageTarget(this.caster, u, this.healPerSecond);
            this.heal.destroy();
        }
        
        private method FireHealAtTarget(unit u) {
            this.missileDummy = xehomingmissile.create(this.casterX + GetRandomInt(-100, 100), this.casterY + GetRandomInt(-100, 100), 1200, u, 20);
            this.missileDummy.fxpath = this.missileEffect;
            this.missileDummy.launch(600, 0.30);
        }
        
        private method tick() {
            group g = CreateGroup();
            unit u;
            GroupEnumUnitsInRange(g, this.casterX, this.casterY, this.radius, null);
            u = FirstOfGroup(g);
            while(u != null) {
                if(UnitManager.isTitan(u) || UnitManager.isMinion(u)) {
                    this.FireHealAtTarget(u);
                    this.HealUnit(u);
                }
                GroupRemoveUnit(g, u);
                u=null;
                u=FirstOfGroup(g);
            }
            u=null;
            DestroyGroup(g);
        }
        
        private static method Begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.casterX = GetUnitX(this.caster);
            this.casterY = GetUnitY(this.caster);
            this.setup(GetUnitAbilityLevel(this.caster, this.abilityId));
            this.aoeDummy = xefx.create(this.casterX, this.casterY, bj_UNIT_FACING); 
            this.aoeDummy.fxpath = this.healAreaEffect;
            this.aoeDummy.z = 900;
            this.periodicTimer = GameTimer.newPeriodic(function (GameTimer t) {
                thistype this = t.data();
                this.tick();
            }).start(this.timerInterval);
            this.periodicTimer.setData(this);
            this.durationTimer = GameTimer.new(function (GameTimer t) {
                thistype this = t.data();
                this.periodicTimer.deleteLater();
                this.durationTimer.deleteLater();
                this.aoeDummy.destroy();
                this.destroy();
            }).start(this.duration);
            this.durationTimer.setData(this);
            return this;
        }
        
        private static method onCast() {
            unit caster = GetSpellAbilityUnit();
            thistype.Begin(caster);
		//insightHeal(caster, BlzGetUnitMaxMana(caster), 0);
        }
        
        private static method onAbilitySetup() {
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
            thistype.onAbilitySetup.execute();
        }
    }
}
//! endzinc