//! zinc
library DemoScouting requires GameTimer, GT, xepreload, xebasic {
    struct DemoScouting {
        private static constant integer abilityId = 'A08J';
        //Transparency ability ID
        private static constant integer dummyId = 'u004';
        private static constant integer visionAbilityId = 'A08G';
        private GameTimer periodicTimer;
        private unit caster;
        private real targetX;
        private real targetY;
        private real AOE;
        private integer numShades = 6;
        private group shadeGroup = CreateGroup();
        private group affectedUnits;
        private real timerInterval = 1;
        private real elapsedTime = 0;
        private boolean finished = false;
        private group targetsGroup = CreateGroup();
        
        private method setup(integer level) {
            //AOE Of The Ability
            this.AOE = 2000 + (250*level);
        }
        
        private method CheckTarget(unit u) -> boolean {
            return (!UnitManager.isTitan(u) && !UnitManager.isMinion(u) && UnitAlive(u));
        }
        
        private method onFinish() {
            unit u;
            group g;
            u = FirstOfGroup(this.affectedUnits);
            while(u != null) {
                UnitRemoveAbility(u, this.visionAbilityId);
                GroupRemoveUnit(this.affectedUnits, u);
                u=null;
                u=FirstOfGroup(this.affectedUnits);
            }
            u=null;
            g=CreateGroup();
            GroupEnumUnitsInRange(g, this.targetX, this.targetY, 99999, null);
            u=FirstOfGroup(g);
            while(u != null) {
                UnitRemoveAbility(u, this.visionAbilityId);
                GroupRemoveUnit(g, u);
                u=FirstOfGroup(g);
            }
            u=null;
            DestroyGroup(g);
            DestroyGroup(this.affectedUnits);
            DestroyGroup(this.shadeGroup);
            DestroyGroup(this.targetsGroup);
            this.periodicTimer.deleteNow();
            this.destroy();
        }
        
        private method checkGroup(unit source) {
            unit u;
            group g = CreateGroup();
            if(!finished) {
                GroupEnumUnitsInRange(g, GetUnitX(source), GetUnitY(source), 600, null);
                u=FirstOfGroup(g);
                while(u!=null) {
                    if(u==this.caster && this.elapsedTime > 10) {
                        GroupRemoveUnit(this.shadeGroup, source);
                        KillUnit(source);
                    } else if(this.CheckTarget(u)) {
                        if(UnitManager.isDefender(u) && !(IsUnitInGroup(u, this.targetsGroup))) {
                            IssueTargetOrder(source, "smart", u);
                            GroupRemoveUnit(this.shadeGroup, source);
                            GroupAddUnit(this.targetsGroup, u);
                        } else {
                            if(GetUnitAbilityLevel(u, this.visionAbilityId) == 0 && !UnitManager.isDefender(u)) {
                                UnitAddAbility(u, this.visionAbilityId);
                                GroupAddUnit(this.affectedUnits, u);
                            }
                        }
                    }
                    GroupRemoveUnit(g, u);
                    u=null;
                    u=FirstOfGroup(g);
                }
            }
            DestroyGroup(g);
            u=null;
        }
        
        private method tick() {
            real casterX;
            real casterY;
            real x;
            real y;
            real distance;
            unit u;
            group g = CreateGroup();
            this.elapsedTime += this.timerInterval;
            GroupAddGroup(this.shadeGroup, g);
            if(CountUnitsInGroup(this.shadeGroup)==0) {
                this.onFinish();
                this.finished = true;
            }
            u=FirstOfGroup(g);
            while(u!=null) {
                if(!UnitAlive(u)) { GroupRemoveUnit(this.shadeGroup, u); }
                x = this.targetX - GetUnitX(u);
                y = this.targetY - GetUnitY(u);
                distance = SquareRoot(x * x + y * y);
                if(distance >= this.AOE) {
                    IssueTargetOrder(u, "smart", this.caster);
                }
                this.checkGroup(u);
                GroupRemoveUnit(g, u);
                u=null;
                u=FirstOfGroup(g);
            }
            DestroyGroup(g);
            u=null;
        }
        
        private method spawnShades() {
            real angle = 360 / this.numShades;
            //How many shades do we have so far?
            real count = 0;
            unit u;
            real newX;
            real newY;
            real distanceToMove = this.AOE + 100;
            for(0 <= count < this.numShades) {
                u=CreateUnit(GetOwningPlayer(this.caster), this.dummyId, this.targetX, this.targetY, bj_DEGTORAD * (angle * count));
                UnitAddAbility(u, 'Aloc');
                UnitApplyTimedLife(u, 'BTLF', 20);
                newX = this.targetX + distanceToMove * Cos(bj_DEGTORAD * (angle * count));
                newY = this.targetY + distanceToMove * Sin(bj_DEGTORAD * (angle * count));
                IssuePointOrder(u, "move", newX, newY);
                GroupAddUnit(this.shadeGroup, u);
            }
        }
        
        private static method Begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.targetX = GetSpellTargetX();
            this.targetY = GetSpellTargetY();
            SetUnitAbilityLevel(this.caster, this.abilityId, GetHeroLevel(this.caster));
            this.setup(GetHeroLevel(this.caster));
            this.affectedUnits = CreateGroup();
            this.spawnShades();
            this.periodicTimer = GameTimer.newPeriodic(function (GameTimer t) {
                thistype this = t.data();
                this.tick();
            }).start(this.timerInterval);
            this.periodicTimer.setData(this);
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