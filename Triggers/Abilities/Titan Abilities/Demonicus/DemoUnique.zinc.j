//! zinc
library DemoUnique requires GT, GameTimer, xebasic, xepreload, IsUnitWall {
    struct DemoUnique {
        private static constant integer abilityId = 'A099';
        private static constant string titanEffect = "war3mapImported\\DemonicusEtherityBuff.mdx";
        private static constant string handEffectString = "war3mapImported\\DemonicusEtherityBuff.mdl";
        private real duration;
        private unit caster;
        private group wallGroup;
        private GameTimer durationTimer;
        private effect cloudEffect;
        private effect handEffect;
        
        private method setup(integer level) {
            this.duration = 3*level;
        }
        
        private static method Begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            unit u;
            this.caster = caster;
            this.setup(GetUnitAbilityLevel(this.caster, this.abilityId));
            UnitAddAbility(this.caster, 'Avul');
            this.cloudEffect = AddSpecialEffectTarget(this.titanEffect, this.caster, "chest");
            this.handEffect = AddSpecialEffectTarget(this.handEffectString, this.caster, "hands");
            this.durationTimer = GameTimer.new(function (GameTimer t) {
                thistype this = t.data();
                UnitRemoveAbility(this.caster, 'Avul');
                DestroyEffect(this.cloudEffect);
                DestroyEffect(this.handEffect);
                this.destroy();
            }).start(this.duration);
            this.durationTimer.setData(this);
            return this;
        }
        
        private static method OnCast() {
            unit caster = GetSpellAbilityUnit();
            thistype.Begin(caster);
        }
        
        private static method OnAbilitySetup() {
            trigger t = CreateTrigger();
            thistype this = thistype.allocate();
            integer id = this.abilityId;
            this.destroy();
            GT_RegisterStartsEffectEvent(t, id);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.OnCast();
                return false;
            }));
            XE_PreloadAbility(id);
        }
        
        private static method onInit() {
            thistype.OnAbilitySetup.execute();
        }
    }
}
//! endzinc