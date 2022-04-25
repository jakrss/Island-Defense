//! zinc
library BreezeriousScouting requires GameTimer, xecast {
    private struct BreezeriousScouting {
        private static integer abilityId = 'A0DB';
        private static integer gustId = 'A0CJ';
        private static integer buffId = 'B041';
        private static integer wwBuffId = 'B03Z';
        private static integer uniqueAbilityId = 'A0D4';
        //Dummy unit has true sight and sight range
        private integer dummyId = 'n02A';
        private integer duration = 35;
        private integer radius = 500;
        private real timerSpeed = .03;
        private unit caster;
        private unit dummyUnit;
        private real casterX;
        private real casterY;
        private integer ticks = 0;
        //GameTimer to apply "Gust" to units
        private GameTimer periodicTimer;
        //GameTimer to end the spell
        private GameTimer durationTimer;
        
        private method CheckTarget(unit u) -> boolean {
            return !IsUnitAlly(u, GetOwningPlayer(this.caster)) &&
                GetWidgetLife(u) > .405 && !(IsUnitType(u, UNIT_TYPE_STRUCTURE)) && 
                IsUnitVisible(u, GetOwningPlayer(this.caster)) && GetUnitAbilityLevel(u, this.buffId) == 0 &&
                !BlzIsUnitInvulnerable(u);
        }
        
        private method tick() {
            group g = CreateGroup();
            unit u=null;
            xecast dummyCaster;
            this.casterX = GetUnitX(this.caster);
            this.casterY = GetUnitY(this.caster);
            SetUnitX(this.dummyUnit, this.casterX);
            SetUnitY(this.dummyUnit, this.casterY);
            SetUnitFacing(this.dummyUnit, GetUnitFacing(this.caster));
            
            if(GetUnitAbilityLevel(this.caster, this.wwBuffId) > 0) {
                UnitAddAbility(this.dummyUnit, 'Apiv');
            } else {
                if(GetUnitAbilityLevel(this.dummyUnit, 'Apiv') > 0) {
                    UnitRemoveAbility(this.dummyUnit, 'Apiv');
                }
            }
            GroupEnumUnitsInRange(g, GetUnitX(this.caster), GetUnitY(this.caster), this.radius, null);
            u=FirstOfGroup(g);
            while(u!=null) {
                if(this.CheckTarget(u)) {
                    dummyCaster = xecast.createBasicA(this.gustId, 852075, GetOwningPlayer(this.caster));
                    dummyCaster.castOnTarget(u);
                }
                GroupRemoveUnit(g, u);
                u=null;
                u=FirstOfGroup(g);
            }
            DestroyGroup(g);
            u=null;
        }
        
        private static method Begin() -> thistype {
            thistype this = thistype.allocate();
            this.caster = GetTriggerUnit();
            this.casterX = GetUnitX(this.caster);
            this.casterY = GetUnitY(this.caster);
            if(GetUnitAbilityLevel(this.caster, this.uniqueAbilityId) > 0) {
                this.duration = this.duration + R2I(7.5 * GetUnitAbilityLevel(this.caster, this.uniqueAbilityId));
            }
            this.dummyUnit = CreateUnit(GetOwningPlayer(this.caster), this.dummyId, this.casterX, this.casterY, GetUnitFacing(this.caster));
            UnitApplyTimedLife(this.dummyUnit, 'BTLF', this.duration);
            this.periodicTimer = GameTimer.newPeriodic(function (GameTimer t) {
                thistype this = t.data();
                this.ticks = this.ticks + 1;
                if((this.ticks * this.timerSpeed) >= this.duration) {
                    this.periodicTimer.deleteLater();
                    this.durationTimer.deleteLater();
                    this.destroy();
                } else {
                    this.tick();
                }
            }).start(this.timerSpeed);
            this.periodicTimer.setData(this);
            this.durationTimer = GameTimer.new(function (GameTimer t) {
                thistype this = t.data();
                this.periodicTimer.deleteLater();
                this.durationTimer.deleteLater();
                this.destroy();
            }).start(this.duration);
            this.durationTimer.setData(this);
            return this;
        }
        
        private static method onInit() {
            trigger t=CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
            TriggerAddCondition(t, function() -> boolean {
                if(GetSpellAbilityId() == thistype.abilityId) {
                    thistype.Begin();
                }
                return false;
            });
            t=null;
        }
    }
}
//! endzinc