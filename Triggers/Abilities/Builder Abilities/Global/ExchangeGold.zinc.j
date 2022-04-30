//! zinc

library ExchangeGold requires ShowTagFromUnit {
	private constant string sExchangeEffect = "Abilities\\Spells\\Items\\ResourceItems\\ResourceEffectTarget.mdl";
	private constant integer iGoldToLumber = 'R057';
	private constant real rBonusCooldown = 600.00;			//The cooldown of the 750 lumber bonus exchange (10 minutes).
	private constant real rStandardCooldown = 300.00;		//The cooldown of the 450 lumber exchange (5 minutes).
	private hashtable hExchangeTable = InitHashtable();
	private constant boolean bDebug = false;

	private function fBonusCooldown() {
		timer tBonus = GetExpiredTimer();
		player pPlayer = LoadPlayerHandle(hExchangeTable, GetHandleId(tBonus), 0);
		SetPlayerTechResearched(pPlayer, iGoldToLumber, 0);	//Return the gold to lumber exchange to leve 0 (750-lumber one).
		FlushChildHashtable(hExchangeTable, GetHandleId(tBonus));
		FlushChildHashtable(hExchangeTable, GetHandleId(pPlayer));	//We can flush player data here, since there cannot be a standard timer left at this point anymore.
		DestroyTimer(tBonus);
		pPlayer = null;
		tBonus = null;
		if(bDebug) BJDebugMsg("|cff90b0d0Bonus Cooldown has expired.");
	}
	private function fStandardCooldown() {	//This marks the end of a 5-minute period (calculated from the first 450/750 lumber exchange since the last 5 minutes.
		timer tStandard = GetExpiredTimer();
		player pPlayer = LoadPlayerHandle(hExchangeTable, GetHandleId(tStandard), 0);
		SetPlayerTechResearched(pPlayer, iGoldToLumber, 1);	//Return the gold to lumber exchange to leve l (450-lumber one).
		FlushChildHashtable(hExchangeTable, GetHandleId(tStandard));
		DestroyTimer(tStandard);
		tStandard = null;
		pPlayer = null;
		if(bDebug) BJDebugMsg("|cff90b0d0Standard Cooldown has expired.");
	}

    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_FINISH);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit uShelter = GetTriggerUnit();
            player pPlayer = GetOwningPlayer(uShelter);
			integer iRate;
			integer iLumber;
			integer i = GetPlayerId(pPlayer);
			timer tBonus;
			timer tStandard;
			if(GetResearched() == iGoldToLumber) {
				tBonus = LoadTimerHandle(hExchangeTable, GetHandleId(pPlayer), 0);
				tStandard = LoadTimerHandle(hExchangeTable, GetHandleId(pPlayer), 1);
				if(tBonus == null) tBonus = CreateTimer();
				if(tStandard == null) tStandard = CreateTimer();
				//Setting ratios and timers:
				iRate = GetPlayerTechCount(pPlayer, iGoldToLumber, false);
				if(iRate >= 3) {
					iLumber = 250;
					SetPlayerTechResearched(pPlayer, iGoldToLumber, 2);	//The research level must not go beyond 3, so always revert it to level 2.
					if(bDebug) BJDebugMsg("|cff90b0d0Reverting Gold to Lumber to level 2.");
				} else {
					if(iRate == 2) iLumber = 450;
					else if(iRate == 1) iLumber = 750;
					//If the standard timer has ran out, it means that no 450-lumber exchange was done in this 5-minute period, so the player can do it again once more.
					if(TimerGetRemaining(tStandard) <= 0.00) {
						SetPlayerTechResearched(pPlayer, iGoldToLumber, 1);
						TimerStart(tStandard, rStandardCooldown, false, function fStandardCooldown);	//The timer inititates at the first 450-research done within any 5 minute period.
						//Hashtable setup for standard timer:
						SaveTimerHandle(hExchangeTable, GetHandleId(pPlayer), 1, tStandard);
						SavePlayerHandle(hExchangeTable, GetHandleId(tStandard), 0, pPlayer);
						if(bDebug) BJDebugMsg("|cff90b0d0Initiating standard timer.");
					}
				}
				TimerStart(tBonus, rBonusCooldown, false, function fBonusCooldown);	//Always start the bonus cooldown, since it only triggers if no exchanges have been done in ten minutes.
				//Hashtable setup for bonus timer:
				SaveTimerHandle(hExchangeTable, GetHandleId(pPlayer), 0, tBonus);
				SavePlayerHandle(hExchangeTable, GetHandleId(tBonus), 0, pPlayer);
				//Actual effects:
				DestroyEffect(AddSpecialEffect(sExchangeEffect, GetUnitX(uShelter), GetUnitY(uShelter)));
				SetPlayerState(pPlayer, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(pPlayer, PLAYER_STATE_RESOURCE_LUMBER) + iLumber);
				ShowTagFromUnitWithColor("+" + I2S(iLumber), uShelter, 50, 205, 50);
			}
			uShelter = null;
			pPlayer = null;
			return false;
		}));
		t = null;
	}
}
//! endzinc