//! zinc
library MorphlingTransformation {
	//Generic:
	private constant boolean SendDebug = true;
	private constant integer utBuilderForm = 'h021';
	private constant integer utWarriorForm = 'h023';
	private constant integer utBeastForm = 'h024';
	//Ability IDs:
	private constant integer aHarvesterMorph = 'A07G';
	private constant integer aBuilderBeast = 'A0MK';
	private constant integer aWarriorBeast = 'A0PH';
	private constant integer aFormSwitch = 'A07E';	//Shifts between Builder and Warrior
	private constant integer aBB2WB = 'A0PI'; //This changes the Builder - Beast into Warrior - Beast
	private constant integer aWB2BB = 'A0PJ'; //This changes the Warrior - Beast into Builder - Beast
	
	//	-	-	-	-	-	-	-	-	-	-
	private constant integer aPanic = 'A07J';
	private constant integer aSlam = 'A0JR';
	private constant integer aHowl = 'A07Z';
	private constant integer aSpines = 'A080';
	private constant integer aBarbs = 'A081';
	//	-	-	-	-	-	-	-	-	-	-
	private constant integer aSpellShield = 'A001';
	private constant integer aShockwave = 'A04E';
	private constant integer aHeroicAura = 'A06M';
	private constant integer aEvasion = 'A07B';
	private constant integer aBash = 'A077';
	private constant integer aCritical = 'A078';
	
	
	private function fromBuilder(unit uMorphling) -> boolean {
		return (GetUnitTypeId(uMorphling) == utBuilderForm);
	}
	
	private function fromWarrior(unit uMorphling) -> boolean {
		return (GetUnitTypeId(uMorphling) == utWarriorForm);
	}
	
	private function fromBeast(unit uMorphling) -> boolean {
		return (GetUnitTypeId(uMorphling) == utBeastForm);
	}

	

	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, Condition(function() -> boolean {
			unit uMorphling = GetTriggerUnit();
			integer aTransformation = GetSpellAbilityId();
			//	By default (after start) Shockwave, Heroic Aura and Warrior - Beast are disabled.
			//	Also Evasion, Bash and Critical are disabled.
			
			//	See when Morphling transforms, we get the unit that it exits from as unit type.
			if(aTransformation == aFormSwitch || aTransformation == aBuilderBeast || aTransformation == aWarriorBeast) {
				//				
				//	Builder:	
				//				
				if(fromBuilder(uMorphling)) {
					BlzUnitDisableAbility(uMorphling, aPanic, true, true);				//	Panic (Hide)
					//Enabled Combat Abilities:
					BlzUnitDisableAbility(uMorphling, aShockwave, false, false);		//	Shockwave (Show)
					BlzUnitDisableAbility(uMorphling, aHeroicAura, false, false);		//	Heroic Aura (Show)
					BlzUnitDisableAbility(uMorphling, aEvasion, false, false);			//	Evasion (Show)
					BlzUnitDisableAbility(uMorphling, aBash, false, false);				//	Bash (Show)
					BlzUnitDisableAbility(uMorphling, aCritical, false, false);			//	Critical (Show)
					//Builder > Warrior
					if(aTransformation == aFormSwitch) {
						BlzUnitDisableAbility(uMorphling, aSlam, false, false);			//	Slam (Show)
						//BJDebugMsg("Builder -> Warrior");
						BlzUnitDisableAbility(uMorphling, aBuilderBeast, true, true);	//	Builder - Beast (Hide)
						BlzUnitDisableAbility(uMorphling, aWarriorBeast, false, false);	//	Warrior - Beast (Show)
						BlzSetAbilityPosX(aWarriorBeast, 3);
						BlzSetAbilityPosY(aWarriorBeast, 0);
					}
					//Builder > Beast
					else if(aTransformation == aBuilderBeast) {
						BlzUnitDisableAbility(uMorphling, aFormSwitch, true, true);		//	Switch (Hide)
						BlzUnitDisableAbility(uMorphling, aSpines, false, false);		//	Deadly Spines (Show)
						BlzUnitDisableAbility(uMorphling, aHowl, false, false);			//	Howl (Show)
						BlzUnitDisableAbility(uMorphling, aBarbs, false, false);		//	Barbs (Show)
						//BJDebugMsg("Builder -> Beast");
						//We do not need to hide/show Builder - Beast since it should be visible in this case (and Warrior - Beast) is not.
					}
				}
				//			
				//	Warrior:
				//			
				if(fromWarrior(uMorphling)) {
					//Warrior -> Builder
					if(aTransformation == aFormSwitch) {
						//Disable Combat Abilities:
						BlzUnitDisableAbility(uMorphling, aSlam, true, true);				//	Slam (Hide)
						BlzUnitDisableAbility(uMorphling, aShockwave, true, false);			//	Shockwave (Hide)
						BlzUnitDisableAbility(uMorphling, aHeroicAura, true, false);		//	Heroic Aura (Hide)
						BlzUnitDisableAbility(uMorphling, aEvasion, true, false);			//	Evasion (Hide)
						BlzUnitDisableAbility(uMorphling, aBash, true, false);				//	Bash (Hide)
						BlzUnitDisableAbility(uMorphling, aCritical, true, false);			//	Critical (Hide)
						//Enable Panic:
						BlzUnitDisableAbility(uMorphling, aPanic, false, false);		//	Panic (Show)
						//BJDebugMsg("Warrior -> Builder");
						BlzUnitDisableAbility(uMorphling, aWarriorBeast, true, true);	//	Warrior - Beast (Hide)
						BlzUnitDisableAbility(uMorphling, aBuilderBeast, false, false);//	Builder - Beast	
						BlzSetAbilityPosX(aBuilderBeast, 3);
						BlzSetAbilityPosY(aBuilderBeast, 0);
					//Warrior -> Beast
					} else if(aTransformation == aWarriorBeast) {
						BlzUnitDisableAbility(uMorphling, aSlam, true, true);			//	Slam (Hide)
						BlzUnitDisableAbility(uMorphling, aFormSwitch, true , true);	//	Switch (Hide)
						BlzUnitDisableAbility(uMorphling, aSpines, false, false);		//	Deadly Spines (Show)
						BlzUnitDisableAbility(uMorphling, aBarbs, false, false);		//	Barbs (Show)
						BlzUnitDisableAbility(uMorphling, aHowl, false, false);			//	Howl (Show)
						//BJDebugMsg("Warrior -> Beast");
					}
				}
				//			
				//	Beast:	
				//			
				if(fromBeast(uMorphling)) {
					BlzUnitDisableAbility(uMorphling, aSpines, true, true);			//	Deadly Spines (Hide)
					BlzUnitDisableAbility(uMorphling, aHowl, true, true);			//	Howl (Hide)
					BlzUnitDisableAbility(uMorphling, aBarbs, true, true);			//	Barbs (Hide)
					//Beast -> Warrior
					if(aTransformation == aWarriorBeast) {
						BlzUnitDisableAbility(uMorphling, aSlam, false, false);			//	Slam (Show)
						BlzUnitDisableAbility(uMorphling, aFormSwitch, false , false );	//	Switch (Show)
						//BJDebugMsg("Beast -> Warrior");
					//Beast -> Builder	
					} else if(aTransformation == aBuilderBeast) {
						//Disable Combat Abilities:
						BlzUnitDisableAbility(uMorphling, aShockwave, true, false);		//	Shockwave (Hide)
						BlzUnitDisableAbility(uMorphling, aHeroicAura, true, false);	//	Heroic Aura (Hide)
						BlzUnitDisableAbility(uMorphling, aEvasion, true, false);		//	Evasion (Hide)
						BlzUnitDisableAbility(uMorphling, aBash, true, false);			//	Bash (Hide)
						BlzUnitDisableAbility(uMorphling, aCritical, true, false);		//	Critical (Hide)
						//Enable Builder Abilities:
						BlzUnitDisableAbility(uMorphling, aPanic, false, false);		//	Panic (Show)
						BlzUnitDisableAbility(uMorphling, aFormSwitch, false , false );	//	Switch (Show)
						//BJDebugMsg("Beast -> Builder");
					}
					
				}
			}
			uMorphling = null;
		return false;
		}));
		t = null;
	}
}
//! endzinc