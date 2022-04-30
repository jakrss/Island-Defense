//! zinc

library GetGold requires GT, UnitManager, ABMA {
    private constant string GOLD_EFFECT = "Abilities\\Spells\\Other\\Transmute\\PileofGold.mdl";
	private boolean bSongEnabled = false;
	private integer iRoll;
	private timer tSongTimer = CreateTimer();
	private real rSongInterval = 2.00;
	private hashtable hGoldStolen = InitHashtable();

	private function fJingleBellsTimer() {
		timer tSongTimer = GetExpiredTimer();
		StopSound(gg_snd_JingleBellsIslandDefense, false, true);
		bSongEnabled = false;
		
	}

    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'A041');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            player p = GetOwningPlayer(u);
            unit v = GetSpellTargetUnit();
			integer iStolenGoldPlayer = LoadInteger(hGoldStolen, GetHandleId(p), 0);
			//Tauren experience:
            if (GetUnitTypeId(u) == 'O01Q'){
                ExperienceSystem.giveExperience(u, 2);
            }
			//Satyr auto-gold (order him to gold again once he finishes the previous gold gained, so he won't go stealthy.
			if (GetUnitTypeId(u) == 'h035') IssueTargetOrderBJ(u,"restoration",v);	//There are some issues with this (getting ordered automatically, but works for now.
			//Christmas Mode:																									
			if(GameSettings.getBool("CHRISTMASMODE_ENABLED")) {
				iRoll = GetRandomInt(0,1000);
				if(!bSongEnabled) {
					if(iRoll > 998) {
						bSongEnabled = true;
						//PlaySoundAtPointBJ(gg_snd_JingleBellsIslandDefense, 100.00, Location(GetUnitX(v), GetUnitY(v)), 1280);
						PlaySoundBJ(gg_snd_JingleBellsIslandDefense);
						TimerStart(tSongTimer, rSongInterval, false, function fJingleBellsTimer);
					}
				} else {
					if(iRoll > 725 && bSongEnabled) {
						TimerStart(tSongTimer, rSongInterval, false, function fJingleBellsTimer);
					}
				}
			}
			//Exit Christmas Mode. . .																							
            SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) + 1);
			iStolenGoldPlayer += 1;
			DestroyEffect(AddSpecialEffect(GOLD_EFFECT, GetUnitX(v), GetUnitY(v)));
            SetUnitState(v, UNIT_STATE_LIFE, GetUnitState(v, UNIT_STATE_MAX_LIFE) / 4.0);
			SaveInteger(hGoldStolen, GetHandleId(p), 0, iStolenGoldPlayer);
			GameSettings.setInt("TITAN_MOUND_GOLD_STOLEN", GameSettings.getInt("TITAN_MOUND_GOLD_STOLEN") + 1);
			//Delay Golding (if the unit never cancels it, we need to update it here):
			if(GameSettings.getBool("GOLDING_DELAY") && GetUnitTypeId(v) == 'h001') {
				if(iStolenGoldPlayer > 135) {
						   if(iStolenGoldPlayer < 180) {
						ABMASetUnitAbilityCooldown(u, 'A041', 1.50);
					} else if(iStolenGoldPlayer < 225) {
						ABMASetUnitAbilityCooldown(u, 'A041', 1.60);
					} else if(iStolenGoldPlayer < 270) {
						ABMASetUnitAbilityCooldown(u, 'A041', 1.70);
					} else if(iStolenGoldPlayer < 315) {
						ABMASetUnitAbilityCooldown(u, 'A041', 1.80);
					} else if(iStolenGoldPlayer < 360) {
						ABMASetUnitAbilityCooldown(u, 'A041', 1.90);
					} else if(iStolenGoldPlayer < 360) {
						ABMASetUnitAbilityCooldown(u, 'A041', 2.00);
					} else if(iStolenGoldPlayer < 405) {
						ABMASetUnitAbilityCooldown(u, 'A041', 2.10);
					}
				}
			}
			//
			
            u = null;
            p = null;
            v = null;
            return false;
        }));
        t = null;
		t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'A0LK');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            player p = GetOwningPlayer(u);
            unit v = GetSpellTargetUnit();
            SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) + 1);
			DestroyEffect(AddSpecialEffect(GOLD_EFFECT, GetUnitX(v), GetUnitY(v)));
            SetUnitState(v, UNIT_STATE_LIFE, GetUnitState(v, UNIT_STATE_MAX_LIFE) / 4.0);
			
			GameSettings.setInt("TITAN_MOUND_GOLD_STOLEN", GameSettings.getInt("TITAN_MOUND_GOLD_STOLEN") + 1);
			
            u = null;
            p = null;
            v = null;
            return false;
        }));
        t = null;
		//Golding Assist AI:
		t = CreateTrigger();
		GT_RegisterTargetOrderEvent(t, 851971);
		TriggerAddCondition(t, Condition(function() -> boolean {
			unit u = GetTriggerUnit();
			unit v = GetOrderTargetUnit();
			real mx = GetUnitX(v);
			real my = GetUnitY(v);
			real xt = GetUnitX(u);
			real yt = GetUnitY(u);
			real angle;
			integer i;
			player p;
			if(GetUnitTypeId(v) == 'h001' && GetUnitAbilityLevel(u, 'A041') > 0 && getDistance(mx, my, xt, yt) > 300 && BlzGetUnitRealField(u, UNIT_RF_ACQUISITION_RANGE) > 300) {
				angle = getAngle(mx, my, xt, yt);
				xt = offsetXTowardsAngle(mx, my, angle, 150);
				yt = offsetYTowardsAngle(mx, my, angle, 150);
				IssuePointOrderById(u, 851986, xt, yt);
			}
			//Set golding-delay if the setting is enabled and if the target of repair is Gold Mound.
			if(GameSettings.getBool("GOLDING_DELAY") && GetUnitTypeId(v) == 'h001' && GetUnitAbilityLevel(u, 'A041') > 0) {
				p = GetOwningPlayer(u);
				i = LoadInteger(hGoldStolen, GetHandleId(p), 0);
				if(i > 135) {
						   if(i < 180) {
						ABMASetUnitAbilityCooldown(u, 'A041', 1.50);
					} else if(i < 225) {
						ABMASetUnitAbilityCooldown(u, 'A041', 1.60);
					} else if(i < 270) {
						ABMASetUnitAbilityCooldown(u, 'A041', 1.70);
					} else if(i < 315) {
						ABMASetUnitAbilityCooldown(u, 'A041', 1.80);
					} else if(i < 360) {
						ABMASetUnitAbilityCooldown(u, 'A041', 1.90);
					} else if(i < 360) {
						ABMASetUnitAbilityCooldown(u, 'A041', 2.00);
					} else if(i < 405) {
						ABMASetUnitAbilityCooldown(u, 'A041', 2.10);
					}
				}
			}
			u = null;
			v = null;
			return false;
		}));
		t = null;
    }
}

//! endzinc