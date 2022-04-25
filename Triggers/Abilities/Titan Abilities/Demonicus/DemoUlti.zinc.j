//! zinc
library DemoUlti requires GameTimer, GT, xepreload, xebasic {
    struct DemoUlti {
        private static constant integer abilityId = 'A09B';
        //Transparency ability ID
        private static constant integer visionAbilityId = 'A09A';
        private static constant integer attackSpeedBuff = 'A08H';
        private GameTimer durationTimer;
        private unit caster;
        private real targetX;
        private real targetY;
        private real AOE;
        private group affectedUnits = CreateGroup();
        private integer duration = 20;
        private real timeElapsed = 0;
        private boolean finished = false;
        
        private method setup() {
            //AOE Of The Ability
            this.AOE = 5000;
        }
        
        private method CheckTarget(unit u) -> boolean {
            return (UnitAlive(u) && !(IsUnitAlly(this.caster, GetOwningPlayer(u))));
        }
        
        private method addVisionAbility() {
            unit u;
            //Group G is all units in the affected area
            group g = CreateGroup();
            //Unit to loop through t
            GroupEnumUnitsInRange(g, this.targetX, this.targetY, this.AOE, null);
            u=FirstOfGroup(g);
            while(u!=null) {
                if(CheckTarget(u)) {
                    GroupAddUnit(this.affectedUnits, u);
                    if(GetUnitAbilityLevel(u, this.visionAbilityId) == 0) {
                        UnitAddAbility(u, this.visionAbilityId);
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
            this.targetX = GetUnitX(this.caster);
            this.targetY = GetUnitY(this.caster);
            this.setup();
            UnitAddAbility(this.caster, this.attackSpeedBuff);
            this.addVisionAbility();
            this.durationTimer = GameTimer.new(function(GameTimer t) {
                thistype this = t.data();
                unit u;
                group g = CreateGroup();
                this.durationTimer.deleteLater();
                UnitRemoveAbility(this.caster, this.visionAbilityId);
                UnitRemoveAbility(this.caster, this.attackSpeedBuff);
                u = FirstOfGroup(this.affectedUnits);
                while(u != null) {
                    UnitRemoveAbility(u, this.visionAbilityId);
                    GroupRemoveUnit(this.affectedUnits, u);
                    u=null;
                    u=FirstOfGroup(this.affectedUnits);
                }
                u=null;
                DestroyGroup(this.affectedUnits);
                GroupEnumUnitsInRange(g, this.targetX, this.targetY, 99999, null);
                u=FirstOfGroup(g);
                while(u != null) {
                    UnitRemoveAbility(u, this.visionAbilityId);
                    GroupRemoveUnit(g, u);
                    u=FirstOfGroup(g);
                }
                u=null;
                DestroyGroup(g);
                this.destroy();
            }).start(this.duration);
            this.durationTimer.setData(this);
            return this;
        }
        
        private static method OnCast() {
            thistype.Begin(GetSpellAbilityUnit());
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