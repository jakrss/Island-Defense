//! zinc
library PandaTransformations requires BUM, PandaRace, UnitManager {
	//Generic:
	private constant integer aStormForm	= 'A0F8';
	private constant integer aEarthForm	= 'A0FA';
	private constant integer aFireForm 	= 'A0B1';
	private constant string eTransformation = "Abilities\\Spells\\Human\\Polymorph\\PolyMorphDoneGround.mdl";
	private constant integer aRefresh = 'A09E'; //This Metamorphosis-based ability refreshes unit's build style.
	private constant integer aHiddenHarvest = 'A0B6';	//Basic form Harvest that must be hidden to make room.
	private constant integer aHarvest = 'A0PJ';

	//Research IDs:
		//Elemental Studies:
	private constant integer rStudiesStorm = 'R03T';
	private constant integer rStudiesEarth = 'R03U';
	private constant integer rStudiesFire = 'R03F';
		//Oaths
	private constant integer rOathStorm = 'R040';
	private constant integer rOathEarth = 'R03X';
	private constant integer rOathFire = 'R03Z';
		//Storm
	private constant integer rStormsEye = 'R048';
	private constant integer rHaste = 'R03M';
	private constant integer rEmpoweredHaste = 'R046';
		//Earth
	private constant integer rEarthsApproval = 'R025';
	private constant integer rPillarOfStone = 'R041';
	private constant integer rFortifiedWalls = 'R03L';
		//Fire
	private constant integer rBurningOil = 'R04A';
	private constant integer rVolcanicActivity = 'R04D';
	private constant integer rEverflame = 'R04B';

	//Stat modifier Research IDs:
	private constant integer ATTACK_RANGE = 'RPAR';
	private constant integer ATTACK_DAMAGE = 'RPAD';
	private constant integer ATTACK_SPEED = 'RPAS';
	private constant integer HIT_POINTS = 'RPHP';
	private constant integer MANA_POINTS = 'RPMP';
	private constant integer LIFE_REGEN = 'RPHR';
	private constant integer MANA_REGEN = 'RPMR';
	private constant integer ARMOR_BONUS = 'RPAB';

	//Unit Skins (these are just sad...)
	private constant integer skinBasic = 'h02D';
	private constant integer skinStorm = 'h04V';
	private constant integer skinEarth = 'h04D';
	private constant integer skinFire  = 'h02N';

	//Ability Setup:
		//Storm Form
	private constant integer aBookOfStorm = 'A0F9';
	private constant integer aStormSkyStrike = 'A0JG';
	private constant integer aStormWindWalk = 'A0GR';
	private constant integer aStormHaste = 'A0H0';
	private constant integer aStormTempest = 'A0H1';
	private constant integer aStormAir = 'A0GO';
	private constant integer aStormFleetFoot = 'S005';
	private constant integer aStormElementalize = 'A0GC';
	private constant integer aStormMarkOfTheWind = 'A0GS';
	private constant integer aStormEssenceCollector = 'A0GI';
		//Earth Form
	private constant integer aBookOfEarth = 'A0FE';
	private constant integer aEarthEarthquake = 'A0G7';
	private constant integer aEarthPillarOfStone = 'A0FX';
	private constant integer aEarthEarthbound = 'A0FC';
	private constant integer aEarthStoneskin = 'A0FN';
	private constant integer aEarthElementalize = 'A0G9';
	private constant integer aEarthRockSolidStrategy = 'A0PK';
	private constant integer aEarthRockSolidStrategyInfo = 'A0PI';
	private constant integer aEarthEssenceCollector = 'A0GI';
		//Fire Form
	private constant integer aBookOfFire = 'A0FF';
	private constant integer aFireBreathOfFire = 'A0H4';
	private constant integer aFireFury = 'A0GJ';
	private constant integer aFireDanceOfFire = 'A0H6';
	private constant integer aFireTwinFigure = 'A0O2';
	private constant integer aFireEnflame = 'A0FO';
	private constant integer aFireBurningOil = 'A0H2';
	private constant integer aFireEmberheart = 'S00K';
	private constant integer aFireElemntalize = 'A0GH';
	private constant integer aFireEssenceCollector = 'A0GI';

	//And here the list goes on...
	
	
	//Hashtable:
	private hashtable fash = InitHashtable();	//Form Hash

	private function isTransformationAbility(integer abilityID) -> boolean {
			return abilityID == aStormForm || abilityID == aEarthForm || abilityID == aFireForm;
		}

	//Setup the available and unavailable structures:
	private function setupStructures(player pPanda, integer iForm) {
		//Arrow Tower:
		if(iForm != 0) SetPlayerTechMaxAllowed(pPanda, 'o02S', 0);
		else SetPlayerTechMaxAllowed(pPanda, 'o02S', -1);
		//Storm Spire:
		if(iForm != 1) SetPlayerTechMaxAllowed(pPanda, 'o02Y', 0);
		else SetPlayerTechMaxAllowed(pPanda, 'o02Y', -1);
		//Earth Wall:
		if(iForm != 2) {
			SetPlayerTechMaxAllowed(pPanda, 'h03E', 0);
			SetPlayerTechMaxAllowed(pPanda, 'h02I', -1);
		} else {
			if(GetPlayerTechCount(pPanda, rEarthsApproval, false) == 2) {
				SetPlayerTechMaxAllowed(pPanda, 'h03E', -1);
				SetPlayerTechMaxAllowed(pPanda, 'h02I', 0);
			} else SetPlayerTechMaxAllowed(pPanda, 'h02I', -1);
		}
		//Volcano:
		if(iForm != 3) SetPlayerTechMaxAllowed(pPanda, 'o01Z', 0);
		else SetPlayerTechMaxAllowed(pPanda, 'o01Z', -1);
	}
	
	private function getSkin(integer iForm) -> integer {
		if(iForm == 0) return skinBasic;
		else if(iForm == 1) return skinStorm;
		else if(iForm == 2) return skinEarth;
		else if(iForm == 3) return skinFire;
		return skinBasic;
	}

	//Updates Panda's build style.
	private function refreshBuildStyle(unit uPanda) {
		UnitRemoveAbility(uPanda, 'AHbu');
		UnitRemoveAbility(uPanda, 'AObu');
		UnitRemoveAbility(uPanda, 'ASbu');
		UnitAddAbility(uPanda, aRefresh);
		UnitRemoveAbility(uPanda, aRefresh);
	}
	
	//Changes Panda's build style to Human:
	private function buildStyleHuman(unit uPanda) {
		refreshBuildStyle(uPanda);
		UnitAddAbility(uPanda, 'A0FU');
		UnitRemoveAbility(uPanda, 'A0FU');
		UnitAddAbility(uPanda, 'A0JD');
		UnitRemoveAbility(uPanda, 'A0JD');
	}
	
	//Changes Panda's build style to Orc:
	private function buildStyleOrc(unit uPanda) {
		refreshBuildStyle(uPanda);
		UnitAddAbility(uPanda, 'A0PB');
		UnitRemoveAbility(uPanda, 'A0PB');
		UnitAddAbility(uPanda, 'A0PD');
		UnitRemoveAbility(uPanda, 'A0PD');
	}
	
	//Changes Panda's build style to Undead:
	private function buildStyleUndead(unit uPanda) {
		refreshBuildStyle(uPanda);
		UnitAddAbility(uPanda, 'A0PC');
		UnitRemoveAbility(uPanda, 'A0PC');
		UnitAddAbility(uPanda, 'A0PE');
		UnitRemoveAbility(uPanda, 'A0PE');
	}
	
	//Setup the new stats upon transformation:
	private function setupStats(unit uPanda, player pPanda, integer iForm) {
		//List of generic stats:
		integer iAttackType = 1;		//Default Attack Type is Physical.	
		integer iDefenseType = 1;	//Default Armor Type is Medium.		
		integer iPreviousForm = LoadInteger(fash, GetHandleId(uPanda), 0);
		real rHitPointIncrement = 0;
		real currentHealthRatio;
		//Modifiers:									
		integer iHIT_POINTS = 0;		//	+10 	Level	
		integer iMANA_POINTS = 0;	//	+5 	Level	
		integer iLIFE_REGEN = 0;		//	+5%	Level	
		integer iMANA_REGEN = 0;		//	+5%	Level 	
		integer iATTACK_DAMAGE = 0;	//	+5 	Level 	
		integer iATTACK_SPEED = 0;	//	+5%	Level	
		integer iATTACK_RANGE = 0;	//	+10	Level	
		integer iARMOR_BONUS = 0;	//	+1 	Level	
		//												
		//Let's substract max health if we're coming from Earth Panda:
		if(iPreviousForm == 2) {
			rHitPointIncrement -= 50 * GetPlayerTechCount(pPanda, rStudiesEarth, false);
			if(GetPlayerTechCount(pPanda, rEarthsApproval, false) >= 1) {
				rHitPointIncrement -= 100; 	//Increase hit points by 100.
			}
		}
		if(GetPlayerTechCount(pPanda, rOathStorm, false) == 2) {
			iMANA_POINTS += 20;	//Increase maximum mana by 100.
			iMANA_REGEN += 20;	//Increase mana regen by 100%.
		} else if(GetPlayerTechCount(pPanda, rOathEarth, false) == 2) {
			//iHIT_POINTS += 15;	//This is applied upon research finish globally to avoid DEATH!
			iARMOR_BONUS += 2;	//Increase armor by 2.
		} else if(GetPlayerTechCount(pPanda, rOathFire, false) == 2) {
			iATTACK_DAMAGE += 5;	//Increase attack damage by 25.
			iATTACK_SPEED += 5; 	//Increase attack speed by 25%.
		}
		//Basic Form:	
		if(iForm == 0) {
			//Refresh Build Style (back to Human).
			buildStyleHuman(uPanda);
		//Storm Form:	
		} else if(iForm == 1) {
			iAttackType = 4;		//Set Attack Type to Magic.
			iATTACK_RANGE += 35;	//Increase range by 350.
			//Increase maximum mana by 25 per Storm Study level:
			iMANA_POINTS += 5 * GetPlayerTechCount(pPanda, rStudiesStorm, false);
			if(GetPlayerTechCount(pPanda, rStormsEye, false) >= 1) {
				iATTACK_DAMAGE += 5;	//Increase attack damage by 25.
				iATTACK_RANGE += 15;	//Increase attack range by 150;
				iATTACK_SPEED += 10;	//Increase attack speed by 50%;
			}	//Storm Form Oath Bonuses:
			if(GetPlayerTechCount(pPanda, rOathStorm, false) > 0) {
				buildStyleUndead(uPanda);
			} else {
				buildStyleHuman(uPanda);
			}
		//Earth Form:	
		} else if(iForm == 2) {
			//Set Armor Type to Heavy.
			iDefenseType = 2;
			//Increase maximum hit poitns by 50 per Earth Study:
			//iHIT_POINTS += 5 * GetPlayerTechCount(pPanda, rStudiesEarth, false);
			rHitPointIncrement += 50 * GetPlayerTechCount(pPanda, rStudiesEarth, false);
			//Increase armor by 5, and 2 per Earth Study:
			iARMOR_BONUS += 3 + 2 * GetPlayerTechCount(pPanda, rStudiesEarth, false);
			if(GetPlayerTechCount(pPanda, rEarthsApproval, false) >= 1) {
				//iHIT_POINTS += 10;	//Increase hit points by 100.
				rHitPointIncrement += 100;
				iLIFE_REGEN += 10;	//Increase life regen by 50%.
			}	//Earth Form Oath Bonuses:
			if(GetPlayerTechCount(pPanda, rOathEarth, false) > 0) {
				buildStyleOrc(uPanda);
			} else {
				buildStyleHuman(uPanda);
			}
		//Fire Form:	
		} else if(iForm == 3) {
			iATTACK_RANGE += 2;	//Increase attack range by 50.
			//Increase attack damage by 25 per Fire Study:
			iATTACK_DAMAGE += 5 + 5 * GetPlayerTechCount(pPanda, rStudiesFire, false);
			//Incease attack speed by 15% per Fire Study:
			iATTACK_SPEED += 2 * GetPlayerTechCount(pPanda, rStudiesFire, false);
			//Fire Form Oath Bonuses:
			if(GetPlayerTechCount(pPanda, rOathFire, false) > 0) {
				iAttackType = 6;		//Heroic Attack Type.
			}
			//Refresh Build Style (back to Human).
			buildStyleHuman(uPanda);
		}
		//Attack Type Change:
		BlzSetUnitWeaponIntegerFieldBJ(uPanda, UNIT_WEAPON_IF_ATTACK_ATTACK_TYPE, 0, iAttackType);
		BlzSetUnitIntegerFieldBJ(uPanda, UNIT_IF_DEFENSE_TYPE, iDefenseType);
		SetPlayerTechResearched(pPanda, ATTACK_DAMAGE, iATTACK_DAMAGE);
		SetPlayerTechResearched(pPanda, ATTACK_RANGE, iATTACK_RANGE);
		SetPlayerTechResearched(pPanda, ATTACK_SPEED, iATTACK_SPEED);
		//SetPlayerTechResearched(pPanda, HIT_POINTS, iHIT_POINTS);
		currentHealthRatio = getRatioHealth(uPanda);
		setHealth(uPanda, getMaxHealth(uPanda));
		addMaxHealth(uPanda, rHitPointIncrement);
		setHealth(uPanda, currentHealthRatio * getMaxHealth(uPanda));
		SetPlayerTechResearched(pPanda, MANA_POINTS, iMANA_POINTS);
		SetPlayerTechResearched(pPanda, LIFE_REGEN, iLIFE_REGEN);
		SetPlayerTechResearched(pPanda, MANA_REGEN, iMANA_REGEN);
		SetPlayerTechResearched(pPanda, ARMOR_BONUS, iARMOR_BONUS);
		BlzSetUnitSkin(uPanda, getSkin(iForm));
		//Clean Up:
		uPanda = null;
		pPanda = null;
	}
	
	//Sets up correct abilities and their levels. Note: Building style is set in setupStats().
	private function setupAbilities(unit uPanda, player pPanda, integer iForm) {
		//Generic:
		UnitRemoveAbility(uPanda, aBookOfStorm);
		UnitRemoveAbility(uPanda, aBookOfEarth);
		UnitRemoveAbility(uPanda, aBookOfFire);
		//Basic Form:	
		if(iForm == 0) {
			BlzUnitDisableAbility(uPanda, aHarvest, false, false);
			BlzUnitDisableAbility(uPanda, aHiddenHarvest, true, true);
		//Storm Form:
		} else if(iForm == 1) {
			BlzUnitDisableAbility(uPanda, aHarvest, true, true);
			BlzUnitDisableAbility(uPanda, aHiddenHarvest, false, false);
			UnitAddAbility(uPanda, aBookOfStorm);
			//Fleet Foot and Wind Walk scale with Storm Studies:
			if(GetPlayerTechCount(pPanda, rStudiesStorm, false) >= 1) {
				SetUnitAbilityLevel(uPanda, aStormWindWalk, 2);
				SetUnitAbilityLevel(uPanda, aStormFleetFoot, 2);
				if(GetPlayerTechCount(pPanda, rStudiesStorm, false) == 3) {
					SetUnitAbilityLevel(uPanda, aStormFleetFoot, 3);
					//Fleet foot's ally bonus is handled by requirement.
				}
			}
			//Haste (same level as the research Haste (unless Empowered Haste is researched):
			SetUnitAbilityLevel(uPanda, aStormHaste, GetPlayerTechCount(pPanda, rHaste, false));
			if(GetPlayerTechCount(pPanda, rEmpoweredHaste, false) == 1) {
				SetUnitAbilityLevel(uPanda, aStormHaste, 4);
			}
			//Wind Walk if Oath:
			if(GetPlayerTechCount(pPanda, rOathStorm, false) >= 1) {
				SetUnitAbilityLevel(uPanda, aStormWindWalk, 3);
			}
		//Earth Form:	
		} else if(iForm == 2) {
			BlzUnitDisableAbility(uPanda, aHarvest, true, true);
			BlzUnitDisableAbility(uPanda, aHiddenHarvest, false, false);
			UnitAddAbility(uPanda, aBookOfEarth);
			if(GetPlayerTechCount(pPanda, rEarthsApproval, false) == 2) { // Holder O Boulder
				SetUnitAbilityLevel(uPanda, aEarthRockSolidStrategy, 1);
				SetUnitAbilityLevel(uPanda, aEarthRockSolidStrategyInfo, 1);
			}
			if(GetPlayerTechCount(pPanda, rPillarOfStone, false) == 1) {
				SetUnitAbilityLevel(uPanda, aEarthRockSolidStrategy, 2);
				SetUnitAbilityLevel(uPanda, aEarthRockSolidStrategyInfo, 2);
			}
		
		//Fire Form:
		} else if(iForm == 3) {
			BlzUnitDisableAbility(uPanda, aHarvest, true, true);
			BlzUnitDisableAbility(uPanda, aHiddenHarvest, false, false);
			UnitAddAbility(uPanda, aBookOfFire);
			SetUnitAbilityLevel(uPanda, aFireBurningOil, (GetPlayerTechCount(pPanda, rBurningOil, false)+1));
			//Set Enflame level (on Fire Studie III):
			if(GetPlayerTechCount(pPanda, rStudiesFire, false) == 3) {
				SetUnitAbilityLevel(uPanda, aFireEnflame, 2);
			}
			//Set ability levels from Everflame Research:
			if(GetPlayerTechCount(pPanda, rEverflame, false) == 1) {
				SetUnitAbilityLevel(uPanda, aFireBreathOfFire, 2);
				SetUnitAbilityLevel(uPanda, aFireDanceOfFire, 2);
				SetUnitAbilityLevel(uPanda, aFireEnflame, 3);
			}
			//Increase Twin Figure duration based on Oath:
			if(GetPlayerTechCount(pPanda, rOathFire, false) >= 1) {
				SetUnitAbilityLevel(uPanda, aFireTwinFigure, 2);
			}

			//Dance Of Fire still needs to increase aFireBurningOil by +1 when active
		}
		uPanda = null;
		pPanda = null;
	}
	
	private function getATransformation(integer iForm) -> integer {
		if(iForm == 1) return aStormForm;
		else if(iForm == 2) return aEarthForm;
		else if(iForm == 3) return aFireForm;
		else return 0;
	}
	
	//Returns the new elemental form of the Panda.
	private function getForm(integer aTransformation, integer iForm) -> integer {
		//If Panda casts Storm Form:
		if(aTransformation == aStormForm && iForm != 1) {
			return 1;
		} else if(aTransformation == aEarthForm && iForm != 2) {
			return 2;
		} else if(aTransformation == aFireForm && iForm != 3) {
			return 3;
		} else {
			return 0; //Panda turns into Basic Form.
		}
	}
	
	private function initiateCooldown(unit uPanda, integer aTransformation) {
		real rCooldown = 180 - 30 * GetUnitAbilityLevel(uPanda, aTransformation);
		if(aTransformation != 0) {
			BlzStartUnitAbilityCooldown(uPanda, aTransformation, rCooldown);
		}
		uPanda = null;
	}
	
	//When the duration timer runs out, we call the form setup for state 0.
	private function formExpiration() {
		timer tFormDuration = GetExpiredTimer();
		unit uPanda = LoadUnitHandle(fash, GetHandleId(tFormDuration), 0);
		player pPanda = GetOwningPlayer(uPanda);
		integer iForm = LoadInteger(fash, GetHandleId(uPanda), 0);
		real rCooldown;
		initiateCooldown(uPanda, getATransformation(iForm));
		setupStructures(pPanda, 0);
		setupStats(uPanda, pPanda, 0);
		setupAbilities(uPanda, pPanda, 0);
		FlushChildHashtable(fash, GetHandleId(uPanda));
		FlushChildHashtable(fash, GetHandleId(tFormDuration));
		DestroyTimer(tFormDuration);
		tFormDuration = null;
		uPanda = null;
		pPanda = null;
	}	
	
	private function setupNewForm(unit uPanda, integer aTransformation, integer iForm) {
		timer tFormDuration = LoadTimerHandle(fash, GetHandleId(uPanda), 1);
		player pPanda = GetOwningPlayer(uPanda);
		real rDuration = TimerGetRemaining(tFormDuration);
		integer iPreviousForm = LoadInteger(fash, GetHandleId(uPanda), 0);
		integer aPreviousAbility = getATransformation(iPreviousForm);
		DestroyTimer(tFormDuration);
		DestroyEffect(AddSpecialEffectTarget(eTransformation, uPanda, "origin"));
		//Then clean up the previous form's stats and apply new ones:
		setupStructures(pPanda, iForm);
		setupStats(uPanda, pPanda, iForm);
		setupAbilities(uPanda, pPanda, iForm);
		//Start cooldown of previous form:
		if(GetUnitAbilityLevel(uPanda, aPreviousAbility) < 5) {
			initiateCooldown(uPanda, aPreviousAbility);
		}
		//If the Panda hasn't sworn Oath and transforms into elemental form:
		if(GetUnitAbilityLevel(uPanda, aTransformation) < 5 && iForm != 0) {
			rDuration = 10 * GetUnitAbilityLevel(uPanda, aTransformation);
			BlzStartUnitAbilityCooldown(uPanda, aTransformation, rDuration);
			tFormDuration = CreateTimer();
			TimerStart(tFormDuration, rDuration-0.10, false, function formExpiration);
			SaveUnitHandle(fash, GetHandleId(tFormDuration), 0, uPanda);
			SaveTimerHandle(fash, GetHandleId(uPanda), 1, tFormDuration);
		//If Oath has been sworn and transforming into elemental form:
		} else if(iForm != 0) {
			BlzStartUnitAbilityCooldown(uPanda, aTransformation, 0.50);
		} else if(iForm == 0 && GetUnitAbilityLevel(uPanda, aTransformation) < 5) {
			//Just in-case of testing (start cooldown if transformation is manually reverted):
			initiateCooldown(uPanda, aTransformation);
		}
		SaveInteger(fash, GetHandleId(uPanda), 0, iForm);
		//Clean Up:
		uPanda = null;
		tFormDuration = null;
		pPanda = null;
	}
	
	private function getPandaUnits() -> boolean {
		return (GetUnitTypeId(GetFilterUnit()) == 'h02D');
	}
	
	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, Condition(function() -> boolean {
			unit uPanda = GetTriggerUnit();
			integer aTransformation = GetSpellAbilityId();
			integer iForm = LoadInteger(fash, GetHandleId(uPanda), 0);
			//When Panda casts a transformation ability, setup new state:
			if(isTransformationAbility(aTransformation)) {
				setupNewForm(uPanda, aTransformation, getForm(aTransformation, iForm));
			}
			uPanda = null;
		return false;
		}));
		t = null;
		
		//Handle enabling and disabling Oath Researches:
		t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_START);
		TriggerAddCondition(t, Condition(function() -> boolean {
			//Oath of Storm:
			if(GetResearched() == 'R040') {
				SetPlayerTechMaxAllowed(GetOwningPlayer(GetTriggerUnit()), 'R03X', 0);	//Disable Earth Oath
				SetPlayerTechMaxAllowed(GetOwningPlayer(GetTriggerUnit()), 'R03Z', 0);	//Disable Fire Oath
				
			//Oath of Earth:
			} else if(GetResearched() == 'R03X') {
				SetPlayerTechMaxAllowed(GetOwningPlayer(GetTriggerUnit()), 'R040', 0);	//Disable Storm Oath
				SetPlayerTechMaxAllowed(GetOwningPlayer(GetTriggerUnit()), 'R03Z', 0);	//Disable Fire Oath
			//Oath of Fire:
			} else if(GetResearched() == 'R03Z') {
				SetPlayerTechMaxAllowed(GetOwningPlayer(GetTriggerUnit()), 'R040', 0);	//Disable Storm Oath
				SetPlayerTechMaxAllowed(GetOwningPlayer(GetTriggerUnit()), 'R03X', 0);	//Disable Earth Oath
			}
		return false;
		}));
		t = null;
		t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_CANCEL);
		TriggerAddCondition(t, Condition(function() -> boolean {
			//Oath of Storm:
			if(GetResearched() == 'R040') {
				SetPlayerTechMaxAllowed(GetOwningPlayer(GetTriggerUnit()), 'R03X', 0);	//Enable Earth Oath
				SetPlayerTechMaxAllowed(GetOwningPlayer(GetTriggerUnit()), 'R03Z', 0);	//Enable Fire Oath
				
			//Oath of Earth:
			} else if(GetResearched() == 'R03X') {
				SetPlayerTechMaxAllowed(GetOwningPlayer(GetTriggerUnit()), 'R040', 0);	//Enable Storm Oath
				SetPlayerTechMaxAllowed(GetOwningPlayer(GetTriggerUnit()), 'R03Z', 0);	//Enable Fire Oath
			//Oath of Fire:
			} else if(GetResearched() == 'R03Z') {
				SetPlayerTechMaxAllowed(GetOwningPlayer(GetTriggerUnit()), 'R040', 0);	//Enable Storm Oath
				SetPlayerTechMaxAllowed(GetOwningPlayer(GetTriggerUnit()), 'R03X', 0);	//Enable Earth Oath
			}
		return false;
		}));
		t = null;
		t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_FINISH);
		TriggerAddCondition(t, Condition(function() -> boolean {
			group gPanda;
			unit uPanda = GetTriggerUnit();
			real currentHealthRatio;
			//Health Upgrade Finished by Panda (Hall of Elements):
			if(GetResearched() == 'R04K' && GetUnitTypeId(uPanda) == 'e01M') {
				gPanda = CreateGroup();
				GroupEnumUnitsOfPlayer(gPanda, GetOwningPlayer(uPanda), function getPandaUnits);
				uPanda = null;
				uPanda = FirstOfGroup(gPanda);
				while(uPanda != null) {
					addMaxHealth(uPanda, 100);	//Add 100 health to Panda.
					addHealth(uPanda, 100);
					GroupRemoveUnit(gPanda, uPanda);
					uPanda = FirstOfGroup(gPanda);
				}
			}
			if(GetResearched() == 'R03X' && GetPlayerTechCount(GetOwningPlayer(uPanda), 'R03X', false) == 2) {
				gPanda = CreateGroup();
				GroupEnumUnitsOfPlayer(gPanda, GetOwningPlayer(uPanda), function getPandaUnits);
				uPanda = null;
				uPanda = FirstOfGroup(gPanda);
				while(uPanda != null) {
					addMaxHealth(uPanda, 150);	//Add 100 health to Panda.
					addHealth(uPanda, 150);
					GroupRemoveUnit(gPanda, uPanda);
					uPanda = FirstOfGroup(gPanda);
				}
			}
			//If we are in Earth Form at the moment:
			if(GetResearched() == rStudiesEarth) {
				gPanda = CreateGroup();
				GroupEnumUnitsOfPlayer(gPanda, GetOwningPlayer(uPanda), function getPandaUnits);
				uPanda = null;
				uPanda = FirstOfGroup(gPanda);
				while(uPanda != null) {
					if(LoadInteger(fash, GetHandleId(uPanda), 0) == 2) {
					addMaxHealth(uPanda, 50);	//Add 100 health to Panda.
					addHealth(uPanda, 50);
					}
					GroupRemoveUnit(gPanda, uPanda);
					uPanda = FirstOfGroup(gPanda);
				}
			}
			//If we are in Earth Form at the moment:
			if(GetResearched() == rEarthsApproval && GetPlayerTechCount(GetOwningPlayer(uPanda), rEarthsApproval, false) == 1) {
				gPanda = CreateGroup();
				GroupEnumUnitsOfPlayer(gPanda, GetOwningPlayer(uPanda), function getPandaUnits);
				uPanda = null;
				uPanda = FirstOfGroup(gPanda);
				while(uPanda != null) {
					if(LoadInteger(fash, GetHandleId(uPanda), 0) == 2) {
					addMaxHealth(uPanda, 100);	//Add 100 health to Panda.
					addHealth(uPanda, 100);
					}
					GroupRemoveUnit(gPanda, uPanda);
					uPanda = FirstOfGroup(gPanda);
				}
			}
			uPanda = null;
			DestroyGroup(gPanda);
			gPanda = null;
		return false;
		}));
		t = null;
		
	}
}
//! endzinc