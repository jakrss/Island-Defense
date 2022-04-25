globals
    group glacLocustGroup = CreateGroup()
endglobals
//! zinc

library GlaciousTrap requires GameTimer, GT, xebasic, xepreload {
    private struct GlaciusTrap {
        private real delayTime;
        //Keeps track of the current time
        private real currentTime;
        private static string spawningEffect;
        private static integer abilityId = 'A09J';
        private static integer dummyId = 'o02F';
        private static integer visionIncrease = 'A0BG';
        private static integer trueSight = 'A0BC';
        private static integer uniqueId = 'TGAR';
        private static integer FrostExplosion = 'TGAQ';
        private static integer ImprovedFrostExplosionL1 = 'A09Y';
        private static integer ImprovedFrostExplosionL2 = 'A0A1';
        private static integer Glac = 'E00J';
        private real targetX;
        private real targetY;
        private real timerSpeed;
        private effect spawnEffect;
        private unit dummyUnit;
        private GameTimer periodicTimer;
        private GameTimer durationTimer;
        private unit caster;
        private real duration;
        private boolean addedAbilities = false;
        private boolean addedTitanAbilities = false;
        
        private method setup() {
            //What's the delay before it actually starts working?
            this.delayTime = 3.0;
            //How fast we want to check
            this.timerSpeed = 1.00;
            //Set the currentTime to 0
            this.currentTime = 0;
            this.duration = 20;
        }
        
        //This function only exists add the ability to the dummy unit
        //And to check if it's still alive
        private method tick(unit glac) {
            integer NukeLevel = GetUnitAbilityLevel(glac, this.FrostExplosion);
            integer UniqueLevel = GetUnitAbilityLevel(glac, this.uniqueId);

            if(this.currentTime >= this.delayTime && !this.addedAbilities) {
                UnitAddAbility(this.dummyUnit, this.visionIncrease);
                UnitAddAbility(this.dummyUnit, this.trueSight);
                this.addedAbilities = true;
                if (!this.addedTitanAbilities) {
                    //titan does not have new nuke
                    BlzUnitDisableAbility(glac, this.FrostExplosion, true, true); //hides normal nuke
                    if (UniqueLevel == 1) {
                        UnitAddAbility(glac, this.ImprovedFrostExplosionL1);
                        SetUnitAbilityLevel(glac, this.ImprovedFrostExplosionL1, NukeLevel);
                        this.addedTitanAbilities = true;
                    } else if (UniqueLevel == 2) {
                        UnitAddAbility(glac, this.ImprovedFrostExplosionL2);
                        SetUnitAbilityLevel(glac, this.ImprovedFrostExplosionL2, NukeLevel);  
                        this.addedTitanAbilities = true;   
                    } 
                }
            }
            if(!UnitAlive(this.dummyUnit)) {
                KillUnit(this.dummyUnit);
                UnitApplyTimedLife(this.dummyUnit, 'BTLF', 2);
                if (this.addedTitanAbilities) {
                    //titan does have new nuke
                    if (UniqueLevel == 1) {
                        UnitRemoveAbility(glac, this.ImprovedFrostExplosionL1);
                    } else if (UniqueLevel == 2) {
                        UnitRemoveAbility(glac, this.ImprovedFrostExplosionL2);     
                    }
                    BlzUnitDisableAbility(glac, this.FrostExplosion, false, false); //unhides normal nuke
                    this.addedTitanAbilities = false;
                }
                this.destroy();
            }
            this.currentTime += this.timerSpeed;
        }
        
        
        private static method begin(unit u) -> thistype {
			thistype this = thistype.allocate();
            this.caster = u;
            this.setup();
            this.targetX = GetSpellTargetX();
            this.targetY = GetSpellTargetY();
            this.dummyUnit = CreateUnit(GetOwningPlayer(this.caster), this.dummyId, this.targetX, this.targetY, bj_UNIT_FACING);
            GroupAddUnit(glacLocustGroup, this.dummyUnit);
            SetUnitAnimation(this.dummyUnit, "Birth");
            this.periodicTimer = GameTimer.newPeriodic(function(GameTimer t){
                thistype this = t.data();
                this.tick(this.caster);
            }).start(this.timerSpeed);
            this.periodicTimer.setData(this);
            this.durationTimer = GameTimer.new(function (GameTimer t) {
                thistype this = t.data();
                KillUnit(this.dummyUnit);
                UnitApplyTimedLife(this.dummyUnit, 'BTLF', 2);
                this.periodicTimer.deleteLater();
                this.durationTimer.deleteLater();
                this.destroy();
            }).start(this.duration);
            this.durationTimer.setData(this);
            return this;
        }
        
        private static method onCast() {
            unit caster = GetSpellAbilityUnit();
            thistype.begin(caster);
        }
        
        public static method onSetup() {
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
                thistype.onSetup();
        }
    }
}

//! endzinc