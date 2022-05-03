//! zinc

//TODO: ANIMATIONS
library FossuriousUnique requires GT, GameTimer, BUM, ABMA, MathLibs {
    private struct FossuriousUnique {
        private static constant integer aUnique = 'A0Q0';
        private static constant integer aUniqueDummy = 'A0QW';
        private static constant integer aBurrowDummy = 'A0QX';
        public static constant integer uCryptTunnel = 'e01E';
        private static constant real rEffectDistance = 74; //distance factor between each effect
        private static constant real tunnelRange = 250.0; //distance to tunnel for instant cast

        public static integer iCryptTunnelCount = 0;

        private static unit uFossurious = null; //fossurious unit
        private static location lChannel = null; //location of fossurious at time of channel
        private static location lTarget = null; //location of target
        private static location lEffect = null; //location of effect animation
        private static integer aLevel = 0; //level of ability

        //required
        private GameTimer tickTimer = 0;
        private GameTimer finishTimer = 0;
		private real rEffectNumber = 0.0; //which tick is it on
        private real rEffectTick = 0.0; //how often to tick
        private boolean bTunnelCreated = false;
        private boolean bDummyAbility = false;
		
		static method abilityId() -> integer {
            return thistype.aUnique;
        }
		
		static method targetEffect() -> string {
			return "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl";
		}

		public method getCaster() -> unit {
			return this.uFossurious;
		}

        private static method begin(unit caster) -> thistype {
            thistype this = thistype.allocate();

            this.uFossurious = caster;
            this.setup();

            this.Tunnel();

            return this;
        }

        private method FinishCast() {
            this.tickTimer.deleteLater();
			this.tickTimer = 0;
            this.rEffectNumber = 4;
            this.finishTimer = GameTimer.newPeriodic(function(GameTimer t){
                thistype this = t.data();
                if (this.bDummyAbility) {
                    UnitRemoveAbility(this.uFossurious, this.aUniqueDummy);
                    BlzUnitDisableAbility(this.uFossurious, this.aUnique, false, false);
                    this.bDummyAbility = false;
                }

                if (this.rEffectNumber == 4) {
                    //cast burrow
                    UnitAddAbility(this.uFossurious, this.aBurrowDummy); //give foss a dummy ability to burrow animate
                    BlzUnitHideAbility(this.uFossurious, this.aBurrowDummy, true); //hide dummy ability
                    IssueImmediateOrderById(this.uFossurious, 852533);
					SetUnitTimeScalePercent(this.uFossurious, 84);
                }
                if (this.rEffectNumber == 3) {
                    SetUnitTimeScalePercent(this.uFossurious, 0)
                    //ShowUnit(this.uFossurious, false); //hide unit
                }
                if (this.rEffectNumber == 2) {
                    SetUnitPosition(this.uFossurious, GetLocationX(this.lTarget), GetLocationY(this.lTarget));
                    //ShowUnit(this.uFossurious, true); //unhide unit
                    SelectUnitForPlayerSingle(this.uFossurious, GetOwningPlayer(this.uFossurious));
                    IssueImmediateOrderById(this.uFossurious, 852533); //unburrow cast
                    SetUnitTimeScalePercent(this.uFossurious, 15);
                }

                CreateTunnelEffect(this.lTarget);
                this.rEffectNumber = this.rEffectNumber - 1;
                if (this.rEffectNumber <= 0) {
                    SetUnitTimeScalePercent(this.uFossurious, 100);
                    SetUnitAnimation(this.uFossurious, "stand");
                    UnitRemoveAbility(this.uFossurious, this.aBurrowDummy); //remove burrow ability
                    this.destroy();
                }
            });
            this.finishTimer.setData(this);
            this.finishTimer.start(1.0);
        }

        private method CreateTunnelEffect(location loc) {
            effect eNew = AddSpecialEffect(this.targetEffect(), GetLocationX(loc)-GetRandomReal(-80,80), GetLocationY(loc)-GetRandomReal(-80,80));
            real rRandom = GetRandomReal(0.80,1.65);
            BlzSetSpecialEffectScale(eNew, rRandom);
            rRandom = GetLocationZ(loc) + GetRandomReal(-5,40);
            BlzSetSpecialEffectHeight(eNew, rRandom);
            DestroyEffect(eNew);
        }

        private method TunnelChannel() { //effect loop
            this.lEffect = this.lChannel; //on first cast, set effect location to location of foss
            this.tickTimer = GameTimer.newPeriodic(function(GameTimer t){
                thistype this = t.data();
                this.lEffect = Location(offsetXTowardsPoint(GetLocationX(this.lEffect), GetLocationY(this.lEffect), GetLocationX(this.lTarget), GetLocationY(this.lTarget), this.rEffectDistance), 
                                        offsetYTowardsPoint(GetLocationX(this.lEffect), GetLocationY(this.lEffect), GetLocationX(this.lTarget), GetLocationY(this.lTarget), this.rEffectDistance));
                CreateTunnelEffect(this.lEffect); //create the tunnel effect at each point
				this.rEffectNumber = this.rEffectNumber - 1;

				if (this.rEffectNumber <= 0) {
                    if (!this.bTunnelCreated) CreateUnit(GetOwningPlayer(this.uFossurious), FossuriousUnique.uCryptTunnel, GetLocationX(this.lChannel), GetLocationY(this.lChannel), GetUnitFacing(this.uFossurious));
					this.bTunnelCreated = true;
                    FinishCast();
				}
            });
            this.tickTimer.setData(this);
            this.tickTimer.start(this.rEffectTick);
        }

        private method Tunnel() {
            if (getUnitsInRange(this.lChannel, this.tunnelRange) == 0) {
                BlzUnitDisableAbility(this.uFossurious, this.aUnique, true, true); //disable ability that has no casting time
                UnitAddAbility(this.uFossurious, this.aUniqueDummy); //give foss a dummy ability that has casting time
                SetUnitAbilityLevel(this.uFossurious, this.aUniqueDummy, this.aLevel); //give foss a dummy ability that has casting time
                IssueImmediateOrderById(this.uFossurious, 852150);
                this.bDummyAbility = true;
                this.TunnelChannel();
            } else {
                this.FinishCast();
            }
        }

        private method getUnitsInRange(location loc, real range) -> integer {
            group g = CreateGroup();
            FossuriousUnique.iCryptTunnelCount = 0;

            GroupEnumUnitsInRange(g, GetLocationX(loc), GetLocationY(loc), range, function() -> boolean {
                return GetUnitTypeId(GetFilterUnit()) == FossuriousUnique.uCryptTunnel && UnitAlive(GetFilterUnit());
            });
            ForGroup(g, function() { FossuriousUnique.iCryptTunnelCount = FossuriousUnique.iCryptTunnelCount + 1; });

            DestroyGroup(g);
            g = null;
            return FossuriousUnique.iCryptTunnelCount;
        }

        private method setup(){
            //setup variables here
            this.uFossurious = getCaster();
            this.lChannel = GetUnitLoc(this.uFossurious);
            this.lTarget = Location(GetSpellTargetX(), GetSpellTargetY());
            this.aLevel = GetUnitAbilityLevel(this.uFossurious, this.abilityId());

            this.rEffectNumber = R2I(getDistance(GetLocationX(this.lChannel), GetLocationY(this.lChannel), GetLocationX(this.lTarget), GetLocationY(this.lTarget)) / this.rEffectDistance);
            if (aLevel == 0) this.destroy(); //this should never ever happen - how do you cast an ability without learning it
            if (aLevel == 1) this.rEffectTick = 19 / this.rEffectNumber;
            if (aLevel == 2) this.rEffectTick = 4 / this.rEffectNumber;
        }
		  
        private method onDestroy(){
            //destroy, cleanup
            RemoveLocation(this.lEffect);
            RemoveLocation(this.lChannel);
            RemoveLocation(this.lTarget);
            this.finishTimer.deleteLater();
			this.finishTimer = 0;
            this.uFossurious = null;
            this.lChannel = null;
            this.lEffect = null;
            this.lTarget = null;
            this.bTunnelCreated = false;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit(); //will this return for channeling
            thistype.begin(caster);
        }
        
        public static method onAbilitySetup(){
            trigger t = CreateTrigger();
            GT_RegisterBeginsChannelingEvent(t, thistype.abilityId()); //channeling event
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            XE_PreloadAbility(thistype.abilityId());
			t = null;
        }
	}
    
    private function onInit(){
        FossuriousUnique.onAbilitySetup.execute();
    }
}

//! endzinc