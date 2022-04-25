//! zinc
library ShadowArts requires BUM, ShowTagFromUnit {
    //How long to hit someone to refresh it
	private constant real PrepareTime = 1.50;					//How long it takes to prepare True Strike?
	private constant integer ShadowDash = 'A0C8';				//Shadow Dash
	private constant integer Evasion = 'A0OD';					//Evasion ability (Shadow Arts).
	private constant integer AttackSpeedAbility = 'XXXX';		//Attack speed bonus to give after DurationFading.
    private constant integer BuffShadowDash = 'B06I';			//Shadow Dash buff (equals 'True' on the attack breaking stealth.
    private constant integer ResearchCombatMaster = 'R030';		//Combat Mastery research ID.
	private constant integer ResearchStealthTraining = 'R031';	//Stealth Training reserach ID.
    private constant integer EvasionLevelBonus = 4;				//Add 3, take 3.
	private constant integer UnitType = 'h035';					//Satyr's unit type.
	private constant integer Fading = 'A0BO';					//Satyr's permanent invisibility.
	private constant integer ResearchManaTraining = 'R02P';		//Satyr Mana Training.
	private constant integer AttackSpeedBonus = 'A0JP';			//Hyper attack speed for one attack.
	private constant integer HandOfTheOutlaw = 'A0LQ';			//Used to donate gold and lumber to allies.
	private constant integer AbilityTheft = 'A0BS';
	private constant integer Ability_Blur = 'A0LR';
	private constant integer Ability_ElixirOfCleansing = 'A06U';
    private hashtable EvasionHash = InitHashtable();
	private hashtable TrueStrikeHash = InitHashtable();
	private hashtable ShadowDashHash = InitHashtable();
	private hashtable FadingHash = InitHashtable();
	private constant boolean ReplenishMana = true;				//Do we want to replenish mana on attacks?
	private constant integer ReplenishManaAmount = 75;			//How much mana do we want to replenish per attack?
	
	//Based on Satyr Plunder, below:
	function donate(unit Satyr, unit Target){
        integer level = GetUnitAbilityLevel(Satyr, HandOfTheOutlaw);
        integer gold = 0;
        integer wood = 0;
        string s = "";
        PlayerData p = PlayerData.get(GetOwningPlayer(Target));
		PlayerData d = PlayerData.get(GetOwningPlayer(Satyr));
        
		wood = 50 * level;
		if(level > 3) {
			if(level < 7) {
				gold = 1;
				} else if(level < 10) {
					gold = 2;
					} else if(level == 10) {
						gold = 4;
					}
		}
		//Satyr is donating to someone else:
		if(GetOwningPlayer(Satyr) != GetOwningPlayer(Target)) {
			//Checking that Satyr can afford it:
			if(GetPlayerState(GetOwningPlayer(Satyr), PLAYER_STATE_RESOURCE_GOLD) >= gold && GetPlayerState(GetOwningPlayer(Satyr), PLAYER_STATE_RESOURCE_LUMBER) >= wood) {
				//Taking from Satyr:
				d.setGold(d.gold() - gold);
				d.setWood(d.wood() - wood);
				//Giving to the target:
				p.setGold(p.gold() + gold);
				p.setWood(p.wood() + wood);
				//Text and reset:
				SetUnitAbilityLevel(Satyr, HandOfTheOutlaw, 1);
				if(wood > 0) {
					if(gold > 0) {
						s = "|cffffd700+" + I2S(gold) + "|r\n\n|ccf01bf4d+" + I2S(wood) + "|r";
					} else {
						s = "|ccf01bf4d+" + I2S(wood);
					}
				ShowTagFromUnit(s, Target);
				s = "";
				}
			} else {
				//Satyr cannot afford it, so let's reset his cooldown:
				BlzEndUnitAbilityCooldown(Satyr, HandOfTheOutlaw);
			}
		//Satyr is donating to himself:
		} else if(GetOwningPlayer(Satyr) == GetOwningPlayer(Target)) {
			//Giving to the target:
			p.setGold(p.gold() + gold);
			p.setWood(p.wood() + wood);
			//Text and reset:
				SetUnitAbilityLevel(Satyr, HandOfTheOutlaw, 1);
				if(wood > 0) {
					if(gold > 0) {
						s = "|cffffd700+" + I2S(gold) + "|r\n\n|ccf01bf4d+" + I2S(wood) + "|r";
					} else {
						s = "|ccf01bf4d+" + I2S(wood);
					}
				ShowTagFromUnit(s, Target);
				s = "";
				}
		}
		Satyr = null;
		Target = null;
    }
	
	//Made by Neco, copied over from Satyr Plunder.
	function plunder(unit attacker, unit attacked){
        integer level = GetHeroLevel(attacked);
        integer gold = 0;
        integer wood = 0;
        string s = "";
        PlayerData p = PlayerData.get(GetOwningPlayer(attacker));
        
        if (level < 4) gold = 2;
        else if (level < 8) gold = 3;
		else if (level < 12) gold = 4;
        else gold = 5;
        
        if (UnitManager.isMinion(attacked)) {
            gold = gold - 1;
        }
        wood = 50 + 25 * level; //50-500 lumber
        if(GetUnitAbilityLevel(attacker, AbilityTheft) == 2) {
		gold = gold * 2;
		wood = wood * 2;
		}
        p.setGold(p.gold() + gold);
        p.setWood(p.wood() + wood);
        
        s = "|cffffd700+" + I2S(gold) + "|r\n\n|ccf01bf4d+" + I2S(wood) + "|r";
        if (GetLocalPlayer() == p.player()) {
            ShowTagFromUnit(s, attacker);
        }
        s = "";
    }
	
	//When the timer for Evasion expire we should reduce the evasion level.
	private function EvasionExpire() {
		timer EvasionTimer = GetExpiredTimer();
		unit Satyr = LoadUnitHandle(EvasionHash, GetHandleId(EvasionTimer), 0);
		SetUnitAbilityLevel(Satyr, Evasion, 1 + GetPlayerTechCount(GetOwningPlayer(Satyr), ResearchCombatMaster, true));
		FlushChildHashtable(EvasionHash, GetHandleId(EvasionTimer));
		FlushChildHashtable(EvasionHash, GetHandleId(Satyr));
		DestroyTimer(GetExpiredTimer());
		Satyr = null;
	}

	private function TrueStrikeFromShadowDash() {
		timer TrueStrikeTimer = GetExpiredTimer();
		unit Satyr = LoadUnitHandle(TrueStrikeHash, GetHandleId(GetExpiredTimer()), 0);
		boolean TrueStrikeReady = true;
		//Let's add the super attack speed:
		UnitAddAbility(Satyr, AttackSpeedBonus);
		UnitRemoveBuffBJ('BIrg', Satyr);		//We count True Strike as combat.
		//Just adding effects:
		AddSpecialEffectTargetUnitBJ("hand left", Satyr, "Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl");
		DestroyEffect(GetLastCreatedEffectBJ());
		AddSpecialEffectTargetUnitBJ("hand right", Satyr, "Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl");
		DestroyEffect(GetLastCreatedEffectBJ());
		//Flushing unnecessary stuff, saving important stuff.
		SaveBoolean(TrueStrikeHash, GetHandleId(Satyr), 1, TrueStrikeReady);
		FlushChildHashtable(TrueStrikeHash, GetHandleId(TrueStrikeTimer));
		DestroyTimer(GetExpiredTimer());
		Satyr = null;
	}
	
	private function TrueStrikeFromFading() {
		timer TrueStrikeTimer = GetExpiredTimer();
		unit Satyr = LoadUnitHandle(FadingHash, GetHandleId(TrueStrikeTimer), 0);
		boolean TrueStrikeReady = true;
		timer FadingTimer;
		//Let's add the super attack speed:
		UnitAddAbility(Satyr, AttackSpeedBonus);
		UnitRemoveBuffBJ('BIrg', Satyr);		//We count True Strike as combat.
		//Just adding effects:
		AddSpecialEffectTargetUnitBJ("hand left", Satyr, "Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl");
		DestroyEffect(GetLastCreatedEffectBJ());
		AddSpecialEffectTargetUnitBJ("hand right", Satyr, "Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl");
		DestroyEffect(GetLastCreatedEffectBJ());
		//Flushing unnecessary stuff, saving important stuff.
		SaveBoolean(TrueStrikeHash, GetHandleId(Satyr), 1, TrueStrikeReady);
		FadingTimer = LoadTimerHandle(FadingHash, GetHandleId(Satyr), 0);
		FlushChildHashtable(FadingHash, GetHandleId(FadingTimer));
		FlushChildHashtable(FadingHash, GetHandleId(Satyr));
	}
	
	private function CheckIfFaded() {
		group GroupSatyr = CreateGroup();
		unit Satyr;
		timer FadingTimer;
		real FadingTimerDuration;
		boolean TrueStrikeReady;
		GroupEnumUnitsOfType(GroupSatyr, UnitId2String('h035'), null);
		Satyr = FirstOfGroup(GroupSatyr);
		while(Satyr != null) {
			FadingTimerDuration = TimerGetRemaining(LoadTimerHandle(FadingHash, GetHandleId(Satyr), 0));
			TrueStrikeReady = LoadBoolean(TrueStrikeHash, GetHandleId(Satyr), 1);
			if(IsUnitInvisible(Satyr, Player(25)) != true) {
				FadingTimer = LoadTimerHandle(FadingHash, GetHandleId(Satyr), 0);
				DestroyTimer(FadingTimer);
				FlushChildHashtable(FadingHash, GetHandleId(Satyr));
				FlushChildHashtable(FadingHash, GetHandleId(FadingTimer));
				FadingTimerDuration = 0;
			}
			if(FadingTimerDuration == 0 && TrueStrikeReady == false && GetPlayerTechCount(GetOwningPlayer(Satyr), ResearchCombatMaster, true) > 0) {
				//BJDebugMsg(TrueStrikeReady);
				FadingTimer = CreateTimer();
				TimerStart(FadingTimer, 9.00 - 1.50 * GetPlayerTechCount(GetOwningPlayer(Satyr), ResearchCombatMaster, true), false, function TrueStrikeFromFading);
				SaveUnitHandle(FadingHash, GetHandleId(FadingTimer), 0, Satyr);
				SaveTimerHandle(FadingHash, GetHandleId(Satyr), 0, FadingTimer);
			}

		GroupRemoveUnit(GroupSatyr, Satyr);
		Satyr = null;
		}
		DestroyGroup(GroupSatyr);
	}
	
	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterTimerEvent(t, 0.20, true);
		TriggerAddAction(t, function CheckIfFaded);
		t = null;
		t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT); //Let's see when Shadow Dash is casted.
		TriggerAddCondition(t, function() -> boolean {
			unit Satyr = GetTriggerUnit();
			unit UnitTarget;
			unit Phantom;
			timer EvasionTimer;
			timer ShadowDashTimer;
			real EvasionDuration;
			timer TrueStrikeTimer;
			real ShadowDashDuration;
			real EvasionDurationLeft;
			sound SoundOnCast;
			real X;
			real Y;
			if(GetSpellAbilityId() == ShadowDash) {
				UnitRemoveAbility(Satyr, Ability_Blur);
				UnitAddAbility(Satyr, Ability_Blur);
				SoundOnCast = CreateSound("Abilities\\Spells\\Orc\\Voodoo\\BigBadVoodooSpellBirth1.wav", false, true, false, 10, 10, "Spells");
				AttachSoundToUnit(SoundOnCast, Satyr);
				SetSoundPitch(SoundOnCast, 2);
				SetSoundDistances(SoundOnCast, 1000, 100000);
				PlaySoundOnUnitBJ(SoundOnCast, 100, Satyr);
				KillSoundWhenDone(SoundOnCast);
				ShadowDashTimer = CreateTimer();
				ShadowDashDuration = 2.0 + GetPlayerTechCount(GetOwningPlayer(Satyr), ResearchCombatMaster, true) * 0.50;
				//If there the time left in EvasionTimer assigned for this unit is less than the duration gained from Shadow Dash activation.
				EvasionDurationLeft = TimerGetRemaining(LoadTimerHandle(EvasionHash, GetHandleId(Satyr), 0));
				//How long should the evasion be?
				EvasionDuration = 0.35 + (0.10 * (GetPlayerTechCount(GetOwningPlayer(Satyr), ResearchStealthTraining, true)));
				if(EvasionDurationLeft < EvasionDuration) {
					EvasionTimer = CreateTimer();
					TimerStart(EvasionTimer, EvasionDuration, false, function EvasionExpire);
					SaveUnitHandle(EvasionHash, GetHandleId(EvasionTimer), 0, Satyr);
					SaveTimerHandle(EvasionHash, GetHandleId(Satyr), 0, EvasionTimer);
					SetUnitAbilityLevel(Satyr, Evasion, 1 + GetPlayerTechCount(GetOwningPlayer(Satyr), ResearchCombatMaster, true) + EvasionLevelBonus);
					}
				//Other stuff:
				SaveTimerHandle(ShadowDashHash, GetHandleId(Satyr), 0, ShadowDashTimer);
				TimerStart(ShadowDashTimer, ShadowDashDuration, false, null);
				
				//Let's grant True Strike, if we should:
				if(GetPlayerTechCount(GetOwningPlayer(Satyr), ResearchCombatMaster, true) > 0) {
					TrueStrikeTimer = CreateTimer();
					SaveTimerHandle(TrueStrikeHash, GetHandleId(Satyr), 0, TrueStrikeTimer);
					SaveUnitHandle(TrueStrikeHash, GetHandleId(TrueStrikeTimer), 0, Satyr);
					TimerStart(TrueStrikeTimer, PrepareTime, false, function TrueStrikeFromShadowDash);
				}
			}
			//Hand of the Outlaw (donating to an ally):
			if(GetSpellAbilityId() == HandOfTheOutlaw) {
				UnitTarget = GetSpellTargetUnit();
				if(!IsUnitEnemy(UnitTarget, GetOwningPlayer(Satyr))) {
					donate(Satyr, UnitTarget);
				}
			}
			//Blur ability, let's summon a phantom and grant bonuses:
			if(GetSpellAbilityId() == Ability_Blur) {
				//Adding and removing invulnerability to cancel targeting.
				UnitAddAbility(Satyr, 'Avul');
				UnitRemoveAbility(Satyr, 'Avul');
				UnitRemoveBuffBJ('BIrg', Satyr); //We count Blur as combat as well.
				X = GetUnitX(Satyr);
				Y = GetUnitY(Satyr);
				Phantom = CreateUnit(GetOwningPlayer(Satyr), 'e01G', X, Y, GetUnitFacing(Satyr));
				UnitApplyTimedLife(Phantom, 'I061', 1);
				IssueImmediateOrder(Phantom, "taunt");
			}
			if(GetSpellAbilityId() == Ability_ElixirOfCleansing) {
				UnitRemoveBuffs(Satyr, false, true);
			}
			Phantom = null;
			Satyr = null;
			UnitTarget = null;
			return false;
		});
		t = null;
		t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
		TriggerAddCondition(t, function() {
			unit Target = GetTriggerUnit();
			unit Satyr = GetEventDamageSource();
			real DamageDealt = GetEventDamage();
			real X = GetUnitX(Satyr);
			real Y = GetUnitY(Satyr);
			location Point = Location(X, Y);
			real FacingAngle = GetUnitFacing(Satyr);
			integer N;
			real ShadowDashDuration;
			timer ShadowDashTimer;
			boolean TrueStrikeReady;
			timer EvasionTimer;
			real EvasionDurationLeft;
			real EvasionDuration;
			//Let's check it is Satyr that is attacking, and that the attack is basic attack.
			if((GetUnitTypeId(Satyr) == UnitType) && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {
				//Let's cleanse Replenish Potion buff from Satyr to prevent cheesing:
				UnitRemoveBuffBJ('BIrg', Satyr);
				//Let's see if the TrueStrikeTimer has ran out for the unit.
				TrueStrikeReady = LoadBoolean(TrueStrikeHash, GetHandleId(Satyr), 1);
				//And if so... lets do the following:
				if(TrueStrikeReady == true) {
					TrueStrikeReady = false;
					//Let's remove the super attack speed and True Strike regardless of the target.
					UnitRemoveAbility(Satyr, AttackSpeedBonus);
					//Let's make the bonus damage and mana gain only affect enemy units though.
					if(IsUnitEnemy(Target, GetOwningPlayer(Satyr))) {
						EvasionDuration = 0.10*GetPlayerTechCount(GetOwningPlayer(Satyr),ResearchStealthTraining, true);
						//BJDebugMsg(I2S(GetPlayerTechCount(GetOwningPlayer(Satyr),ResearchStealthTraining, true)));
						SaveBoolean(TrueStrikeHash, GetHandleId(Satyr), 1, TrueStrikeReady);
						//Let's grant him Evasion on True Strike for a moment, but we need to check if he already has it... ...or do we?
						EvasionDurationLeft = TimerGetRemaining(LoadTimerHandle(EvasionHash, GetHandleId(Satyr), 0));
						//If duration left in already existing timer is more than 0.50 seconds, let's replace it:
						if(EvasionDurationLeft < EvasionDuration ) {
							EvasionTimer = (LoadTimerHandle(EvasionHash, GetHandleId(Satyr), 0));
							DestroyTimer(EvasionTimer);
							FlushChildHashtable(EvasionHash, GetHandleId(EvasionTimer));
							FlushChildHashtable(EvasionHash, GetHandleId(Satyr));
							EvasionTimer = CreateTimer();
							SaveUnitHandle(EvasionHash, GetHandleId(EvasionTimer), 0, Satyr);
							SaveTimerHandle(EvasionHash, GetHandleId(Satyr), 0, EvasionTimer);
							TimerStart(EvasionTimer, EvasionDuration, false, function EvasionExpire);
							SetUnitAbilityLevel(Satyr, Evasion, 1 + GetPlayerTechCount(GetOwningPlayer(Satyr), ResearchCombatMaster, true) + EvasionLevelBonus);
							//If the duration is more, let's do nothing about it:
						}
						//Let's make fancy effects upon True Strike:
						N = 0;
						while( N <= 8) {
							AddSpecialEffectLoc("Abilities\\Spells\\Human\\Feedback\\ArcaneTowerAttack.mdl", PolarProjectionBJ(Point, 85, FacingAngle + (45 * N)));
							DestroyEffect(GetLastCreatedEffectBJ());
							N = (N + 1);
						}
						//Let's see if the Satyr is also Shadow Dashing (and do something if it matters):
						ShadowDashTimer = LoadTimerHandle(ShadowDashHash, GetHandleId(Satyr), 0);
						ShadowDashDuration = TimerGetRemaining(ShadowDashTimer);
						if(ShadowDashDuration > 0 && GetPlayerTechCount(GetOwningPlayer(Satyr), ResearchCombatMaster, true) >= 1) {
							DamageDealt = DamageDealt * ((1 + (0.45 * GetPlayerTechCount(GetOwningPlayer(Satyr), ResearchCombatMaster, true))) * (1 + (0.15 * GetPlayerTechCount(GetOwningPlayer(Satyr), ResearchCombatMaster, true))));
						//If not, we set the damage to be the normal amplification:
							} else {
							DamageDealt = (DamageDealt * (1 + 0.45 * GetPlayerTechCount(GetOwningPlayer(Satyr), ResearchCombatMaster, true)));
							}
						BlzSetEventDamage(DamageDealt);
						DestroyTimer(ShadowDashTimer);
						FlushChildHashtable(ShadowDashHash, GetHandleId(ShadowDashTimer));
						FlushChildHashtable(TrueStrikeHash, GetHandleId(Satyr));
						//Do we want to replenish mana for Satyr on attacks?
						if(ReplenishMana == true && GetPlayerTechCount(GetOwningPlayer(Satyr), ResearchManaTraining, true) > 0) {
							addMana(Satyr, ReplenishManaAmount);	//Uses the addMana function in Basic Unit Manager (BUM).
						}
					}
				}
				//Let's code Theft passive here. So let's check that the target is a Titanous unit.
				if(GetUnitAbilityLevel(Target, 'CTIT') > 0) {
					plunder(Satyr, Target);
					if(GetPlayerTechCount(GetOwningPlayer(Satyr), 'R02W', true) > 0 ) {
						if(GetUnitAbilityLevel(Satyr, HandOfTheOutlaw) < 10) { IncUnitAbilityLevel(Satyr, HandOfTheOutlaw); }
						if(GetUnitAbilityLevel(Satyr, AbilityTheft) == 2 && GetUnitAbilityLevel(Satyr, HandOfTheOutlaw) < 10) { IncUnitAbilityLevel(Satyr, HandOfTheOutlaw); }
					}
				}
				
			}
			//Blur here, just check for the buff granted by the ability:
			if(UnitHasBuffBJ(Target, 'B02F')) {
				BlzSetEventDamage(0);
			}
			Point = null;
			Target = null;
			Satyr = null;
		});
		t = null;
	}
}
//! endzinc