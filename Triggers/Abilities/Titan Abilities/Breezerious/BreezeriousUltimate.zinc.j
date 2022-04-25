//! zinc
library BreezeriousUltimate requires GameTimer, xecast, xefx {
    private struct BreezeriousUltimate {
        private static integer abilityId = 'A0CY';
        private static integer dummyAbilityId = 'A0D0';
        private static integer windGustId = 'u00U';
        private static integer dummyUnitId = 'u00V';
        private unit caster;
        private real castX;
        private real castY;
        //AOE of the ability
        private real AOE = 3000;
        private real duration = 45;
        //If you change the below change the number of units in the array for WindUnits and WindAngle
        private integer numWindUnits = 100;
        private integer countWindUnits = 0;
        private unit windUnits[100];
        private real windAngle[100];
        private real offsets[100];
        private unit dummyUnits[500];
        private real angle[500];
        //We'll create a unit every X timer intervals
        private real unitCreation = 0;
        private real windCreation = 0;
        private integer dummyCount = 0;
        //Cyclone Curse Radius
        private real cycloneRadius = 100;
        private real timerSpeed = .03125;
        private real elapsedTime = 0;
        //How long does it take the cyclone to travel across the radius?
        private real travelDuration = 6;
        //How many angles per second we rotate
        private real rotationSpeed = 40 * timerSpeed;
        private GameTimer periodicTimer;
        
        private method CheckTarget(unit u) -> boolean {
            return IsUnitEnemy(u, GetOwningPlayer(this.caster));
        }
        
        private method tick() {
            integer i, z;
            real offsetx, offsety, distance, speed, dx, dy;
            xecast dCaster;
            group g;
            unit u=null;
            this.elapsedTime += this.timerSpeed;
            this.unitCreation += this.timerSpeed;
            if(this.elapsedTime > 5) {
                if(this.unitCreation > 1 && this.duration-this.elapsedTime > 1) {
                    this.unitCreation = 0;
                    this.angle[this.dummyCount] = GetRandomReal(0, 360);
                    offsetx = this.castX + (this.AOE-(GetRandomReal(100, 500))) * Cos(this.angle[this.dummyCount] * bj_DEGTORAD);
                    offsety = this.castY + (this.AOE-(GetRandomReal(100, 500))) * Sin(this.angle[this.dummyCount] * bj_DEGTORAD);
                    this.dummyUnits[this.dummyCount] = CreateUnit(GetOwningPlayer(this.caster), this.dummyUnitId, offsetx, offsety, bj_UNIT_FACING);
                    this.angle[this.dummyCount] = this.angle[this.dummyCount] - 180;
                    UnitApplyTimedLife(this.dummyUnits[this.dummyCount], 'BTLF', this.duration-this.elapsedTime);
                    this.dummyCount += 1;
                }
                for(0<=i<=this.dummyCount) {
                    if(UnitAlive(this.dummyUnits[i])) {
                        speed = (this.AOE/this.travelDuration)*this.timerSpeed;
                        offsetx = GetUnitX(this.dummyUnits[i]) + speed * Cos(this.angle[i] * bj_DEGTORAD);
                        offsety = GetUnitY(this.dummyUnits[i]) + speed * Sin(this.angle[i] * bj_DEGTORAD);
                        dx = offsetx - this.castX;
                        dy = offsety - this.castY;
                        distance = SquareRoot(dx * dx + dy * dy);
                        if(distance > this.AOE) {
                            KillUnit(this.dummyUnits[i]);
                        } else {
                            SetUnitX(this.dummyUnits[i], offsetx);
                            SetUnitY(this.dummyUnits[i], offsety);
                        }
                        g=CreateGroup();
                        GroupEnumUnitsInRange(g, offsetx, offsety, this.cycloneRadius, null);
                        u=FirstOfGroup(g);
                        while(u!=null) {
                            if(this.CheckTarget(u)) {
                                dCaster = xecast.createBasicA(this.dummyAbilityId, 852190, GetOwningPlayer(this.caster));
                                dCaster.castOnTarget(u);
                            }
                            GroupRemoveUnit(g, u);
                            u=null;
                            u=FirstOfGroup(g);
                        }
                        DestroyGroup(g);
                        u=null;
                    }
                }
            }
            this.windCreation += this.timerSpeed;
            if(this.windCreation >= 2) {
                this.windCreation = 0;
                if(this.countWindUnits>0) {
                    this.windAngle[this.countWindUnits] = this.windAngle[this.countWindUnits-1] + 60;
                }
                this.offsets[this.countWindUnits] = 100;
                offsetx = this.castX + this.offsets[this.countWindUnits] * Cos(this.windAngle[this.countWindUnits] * bj_DEGTORAD);
                offsety = this.castY + this.offsets[this.countWindUnits] * Sin(this.windAngle[this.countWindUnits] * bj_DEGTORAD);
                this.windUnits[this.countWindUnits] = CreateUnit(GetOwningPlayer(this.caster), this.windGustId, offsetx, offsety, bj_UNIT_FACING);
                UnitApplyTimedLife(this.windUnits[this.countWindUnits], 'BTLF', this.duration-this.elapsedTime);
                this.countWindUnits += 1;
            }
            for(0<=z<=this.countWindUnits) {
                this.windAngle[z] += this.rotationSpeed * 2;
                this.offsets[z] += (this.AOE/this.duration)*this.timerSpeed;
                offsetx = this.castX + this.offsets[z] * Cos(this.windAngle[z] * bj_DEGTORAD);
                offsety = this.castY + this.offsets[z] * Sin(this.windAngle[z] * bj_DEGTORAD);
                SetUnitX(this.windUnits[z], offsetx);
                SetUnitY(this.windUnits[z], offsety);
            }
            if(this.elapsedTime > this.duration) {
                g = CreateGroup();
                GroupEnumUnitsOfPlayer(g, GetOwningPlayer(this.caster), null);
                u=FirstOfGroup(g);
                while(u!=null) {
                    if(GetUnitTypeId(u) == this.dummyUnitId || GetUnitTypeId(u) == this.windGustId) {
                        GroupRemoveUnit(g, u);
                        RemoveUnit(u);
                    } else {
                        GroupRemoveUnit(g, u);
                    }
                    u=null;
                    u=FirstOfGroup(g);
                }
                this.periodicTimer.deleteNow();
                this.destroy();
            }
        }
        
        private static method Begin() -> thistype {
            thistype this = thistype.allocate();
            integer i, z;
            real offsetx, offsety;
            this.caster = GetTriggerUnit();
            this.castX = GetUnitX(this.caster);
            this.castY = GetUnitY(this.caster);
            this.windAngle[0] = 0;
            this.periodicTimer = GameTimer.newPeriodic(function (GameTimer t) {
                thistype this = t.data();
                this.tick();
            }).start(this.timerSpeed);
            this.periodicTimer.setData(this);
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