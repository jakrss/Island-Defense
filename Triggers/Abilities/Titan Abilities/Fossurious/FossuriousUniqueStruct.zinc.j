//! zinc
library FossuriousUnique requires GT, GameTimer, BUM, ABMA {
    private struct FossuriousUnique {
        private static constant integer aUnique = 'A0Q0';
        private static constant integer uCryptTunnel = 'e01E';
        private static constant real rEffectDistance = 74; //distance between each effect

        public static hashtable hTunneling = null; //hash table - do i want this?
        private static unit uFossurious = null; //fossurious unit
        private static location lChannel = null; //location of fossurious at time of channel
        private static location lTarget = null; //location of target
        private static location lEffect = null; //location of effect animation
        private static integer alevel = 0; //level of ability


        //configurable
        private real tunnelRange = 125.0;

        //required
        private GameTimer tickTimer = 0;
        private GameTimer finishTimer = 0;
		private real rEffectNumber = 0.0; //which tick is it on
        private real rEffectTick = 0.0; //how often to tick
		
		method abilityId() -> integer {
            return thistype.aUnique;
        }
		
		method targetEffect() -> string {
			return "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl";
		}

		public method getCaster() -> unit {
			return this.caster;
		}

        private method FinishCast() {
            this.finishTimer = GameTimer.new(function(GameTimer t){
                thistype this = t.data();
                integer c = 0;
                SetUnitPosition(this.uFossurious, GetLocationX(this.lTarget), GetLocationY(this.lTarget));
                while(c < 9) {
                    this.CreateTunnelEffect(GetLocationX(this.lTarget), GetLocationY(this.lTarget));
                    c += 1;
                }
                SetUnitAnimation(uFossurious, "morph defend");
                this.destroy();
            });
            this.finishTimer.setData(this);
            this.finishTimer.start(1.0);
        }

        private method CreateTunnelEffect() {
            effect eNew = AddSpecialEffect(this.targetEffect(), GetLocationX(this.lEffect)-GetRandomReal(-80,80), GetLocationY(this.lEffect)-GetRandomReal(-80,80));
            real rRandom = GetRandomReal(0.80,1.65);
            BlzSetSpecialEffectScale(eNew, rRandom);
            rRandom = GetLocationZ(this.lEffect) + GetRandomReal(-5,40);
            BlzSetSpecialEffectHeight(eNew, rRandom);
            DestroyEffect(eNew);
        }

        private method TunnelChannel() { //effect loop
            this.lEffect = this.lChannel //on first cast, set effect location to location of foss
            this.tickTimer = GameTimer.newPeriodic(function(GameTimer t){ //REVISIT LOGIC OF THIS LOOP
                thistype this = t.data();
                this.lEffect = Location(offsetXTowardsPoint(GetLocationX(this.lEffect), GetLocationY(this.lEffect), GetLocationX(this.lTarget), GetLocationY(this.lTarget), this.rEffectDistance), 
                                        offsetYTowardsPoint(GetLocationX(this.lEffect), GetLocationY(this.lEffect), GetLocationX(this.lTarget), GetLocationY(this.lTarget), this.rEffectDistance));
                CreateTunnelEffect(); //create the tunnel effect at each point
				this.rEffectNumber = this.rEffectNumber - 1;

				if (this.rEffectNumber >= (this.rEffectTick * this.rEffectNumber) || !this.rEffectNumber()) {
                    CreateUnit(GetOwningPlayer(this.uFossurious), this.uCryptTunnel, GetLocationX(this.lChannel), GetLocationY(this.lChannel), GetUnitFacing(this.uFossurious));
					SetUnitAnimation(this.uFossurious, "morph");
                    FinishCast();
				}
            });
            this.tickTimer.setData(this);
            this.tickTimer.start(thistype.rEffectTick);
        }

        private method TunnelInstant() {
            SetUnitAnimation(this.uFossurious, "morph");
            this.FinishCast();
        }

        private method Tunnel() {
            if (getUnitsInRange(this.lChannel, this.uCryptTunnel, this.tunnelRange) == 0) {
                this.TunnelChannel();
            } else {
                this.TunnelInstant();
            }
        }

        private method getUnitsInRange(location loc, integer uID, real range) -> integer {
            //function returns a amount units of type in range of location
            filterfunc uFilterTunnel = Filter(function() -> boolean {
                return GetUnitTypeId(GetFilterUnit()) == uID && UnitAlive(GetFilterUnit());
            });
            group g;
            integer count = 0;

            GroupEnumUnitsInRange(g, GetLocationX(loc), GetLocationY(loc), range, function uFilterTunnel);
            ForGroup(g, function() { count = count + 1; });

            return count;
        }

        private method setup(){
            //setup variables here
            this.hTunneling = InitHashtable();
            this.uFossurious = getCaster();
            this.lChannel = GetUnitLoc(this.uFossurious);
            this.lTarget = GetLocation(GetSpellTargetX(), GetSpellTargetY())
            this.aLevel = GetUnitAbilityLevel(this.uFossurious, this.abilityId());

            this.rEffectNumber = R2I(getDistance(GetLocationX(this.lChannel), GetLocationY(this.lChannel), GetLocationX(this.lTarget), GetLocationY(this.lTarget)) / this.rEffectDistance);
            if (aLevel == 0) this.destroy(); //this should never ever happen - how do you cast an ability without learning it
            if (aLevel == 1) this.rEffectTick = 19 / this.rEffectNumber;
            if (aLevel == 2) this.rEffectTick = 4 / this.rEffectNumber;
        }
        
        private static method begin(unit caster) -> thistype {
            thistype this = thistype.allocate();

            this.caster = caster;
            this.setup();

            this.Tunnel();

            return this;
        }
		  
        private method onDestroy(){
            //destroy, cleanup
            RemoveLocation(this.lEffect);
            RemoveLocation(this.lChannel);
            RemoveLocation(this.lTarget);
            this.tickTimer.deleteLater();
			this.tickTimer = 0;
            this.finishTimer.deleteLater();
			this.finishTimer = 0;
            FlushParentHashtable(this.hTunneling);
            this.hTunneling = null;
            this.uFossurious = null;
            this.lChannel = null;
            this.lEffect = null;
            this.lTarget = null;
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