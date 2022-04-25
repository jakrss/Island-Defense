//! zinc

library VoltronHeal requires GT, GameTimer, xebasic, xepreload, xefx, Healing {
	private struct VoltronHeal {
        integer abilityId = 'A07Y';
        integer abilityLevel;
        integer healAmount;
        integer alliesHealAmount;
        //Volts/His Minis Buff ID
        //Both buff ID's are the same, FYI
		integer discharge = 'B077';
        integer healRadius;
        unit caster;
        unit triggerUnit;
        real casterX;
        real casterY;
        real duration;
		real canceltime;
        boolean killUnits;
        boolean requireBuilder;
        static string groundEffect;
        static string healEffect;
        xefx dummyUnit;
        GameTimer periodicTimer;
        GameTimer durationTimer;
		GameTimer effectTimer;
        effect groundSpecialEffect;
        private xedamage heal;
        
        private method Setup(integer level) {
            //How much should it heal for?
            this.healAmount = 200 + 200*level;
            //The amount it heals allies
            this.alliesHealAmount = 100 + 100*level;
            //The radius of the heal
            this.healRadius = 500;
            //The X and Y to compare to of the casted mark
            this.duration = 23;
            //Should we kill non-hero units that step on it?
            this.killUnits = false;
            //Is it a builder that's required to step on it?
            this.requireBuilder = true;
            //Alternative - "Doodads\\Cityscape\\Props\\MagicRunes\\MagicRunes1.mdx"
            this.groundEffect = "Abilities\\Spells\\Orc\\LightningShield\\LightningShieldTarget.mdx";
            this.healEffect = "Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl";
        }
        
        private static method damageFactor() -> real {
            return 1.33;
        }
        
        private method HealUnit(unit u) {
            DestroyEffect(AddSpecialEffectTarget(this.healEffect, u, "origin"));
            this.heal = xedamage.create();
            this.heal.damageSelf = true;
            this.heal.damageAllies = true;
            this.heal.damageEnemies = false;
            this.heal.damageNeutral = false;
            this.heal.allyfactor = -1.0;
            
            if(this.triggerUnit == u) {
            this.heal.damageTarget(this.caster, u, this.healAmount * this.damageFactor());
            } else {
            this.heal.damageTarget(this.caster, u, this.alliesHealAmount * this.damageFactor());
            }
            this.heal.destroy();
        }
        
        //Method that runs when a Titan or Mini triggers the heal
        private method OnTrigger(unit u) {
            //Our group of titan and minis
            group g = CreateGroup();
            //The unit that triggered it
            unit primaryHeal = u;
            //Our temp unit to loop through the group
            unit tu = null;
            GroupEnumUnitsInRange(g, this.casterX, this.casterY, this.healRadius, null);
            tu = FirstOfGroup(g);
            while(tu != null) {
                //If the unit is the titan or minis
                if(UnitManager.isMinion(tu) || UnitManager.isTitan(tu)) {
                    //Heal the unit and create the special effect
                    this.HealUnit(tu);
                }
                //Remove the unit
                GroupRemoveUnit(g, tu);
                tu = null;
                tu = FirstOfGroup(g);
            }
            //Cleanup
            DestroyGroup(g);
            tu = null;
            this.durationTimer.deleteLater();
            this.periodicTimer.deleteLater();
            this.dummyUnit.destroy();
            this.destroy();
        }
        
        public method tick() {
            group g = CreateGroup();
            unit u = null;
            GroupEnumUnitsInRange(g, this.casterX, this.casterY, 200, null);
            u = FirstOfGroup(g);
            //If the first unit is equal to null there's no units
            while(u != null) {
                if(GetUnitAbilityLevel(u, this.discharge) > 0) {
                    //Titan or Minion has Discharge
                    //Do action of healing and special effects
                    this.triggerUnit = u;
                    OnTrigger(u);
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
            this.Setup(GetUnitAbilityLevel(this.caster, this.abilityId));
            this.casterX = GetUnitX(this.caster);
            this.casterY = GetUnitY(this.caster);
            //Start timer here to check for units
            this.dummyUnit = xefx.create(this.casterX, this.casterY, GetUnitFacing(this.caster) * bj_DEGTORAD);
            this.dummyUnit.fxpath = this.groundEffect;
            this.dummyUnit.x = this.casterX;
            this.dummyUnit.y = this.casterY;
            this.dummyUnit.z = 10;
            this.healAmount = this.healAmount + R2I(getInsightBonus(this.caster));
            //Start our two timers (one to check collision the other to end the current mark
            this.periodicTimer = GameTimer.newPeriodic(function(GameTimer t){
                thistype this = t.data();
                this.tick();
            }).start(.5);
            this.periodicTimer.setData(this);
            this.durationTimer = GameTimer.new(function(GameTimer t) {
                thistype this = t.data();
                this.durationTimer.deleteLater();
                this.periodicTimer.deleteLater();
                this.dummyUnit.destroy();
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