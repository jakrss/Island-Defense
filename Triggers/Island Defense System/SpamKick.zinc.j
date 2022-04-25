//! zinc
library SpamKick requires Dialog, TweakManager {
	private constant boolean SendDebug = false;
	private hashtable Hash = InitHashtable();
	
	function SlowSpamHandler() {
		timer TimerSlow = GetExpiredTimer();
		player p = LoadPlayerHandle(Hash, GetHandleId(TimerSlow), 0);
		integer CountSlow = LoadInteger(Hash, GetHandleId(p), 0);
		if(CountSlow > 0) { CountSlow = CountSlow - 1; }
		if(CountSlow <= 0) {
		FlushChildHashtable(Hash, GetHandleId(TimerSlow));
		DestroyTimer(TimerSlow); 
		}
		if(SendDebug) { BJDebugMsg("Slow " + I2S(CountSlow)); }
		SaveInteger(Hash, GetHandleId(p), 0, CountSlow);
		TimerStart(TimerSlow, 0.5, true, function SlowSpamHandler);
		TimerSlow = null;
		p = null;
	}

	function FastSpamHandler() {
		timer TimerFast = GetExpiredTimer();
		player p = LoadPlayerHandle(Hash, GetHandleId(TimerFast), 0);
		integer CountFast = LoadInteger(Hash, GetHandleId(p), 1);
		if(CountFast > 0) { CountFast = CountFast - 1; }
		if(CountFast <= 0) {
		FlushChildHashtable(Hash, GetHandleId(TimerFast));
		DestroyTimer(TimerFast); 
		}
		if(SendDebug) { BJDebugMsg("Fast " + I2S(CountFast)); }
		SaveInteger(Hash, GetHandleId(p), 1, CountFast);
		TimerStart(TimerFast, 0.1, true, function FastSpamHandler);
		TimerFast = null;
		p = null;
	}
	
	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterPlayerChatEvent(t, Player(0), "", false);
		TriggerRegisterPlayerChatEvent(t, Player(1), "", false);
		TriggerRegisterPlayerChatEvent(t, Player(2), "", false);
		TriggerRegisterPlayerChatEvent(t, Player(3), "", false);
		TriggerRegisterPlayerChatEvent(t, Player(4), "", false);
		TriggerRegisterPlayerChatEvent(t, Player(5), "", false);
		TriggerRegisterPlayerChatEvent(t, Player(6), "", false);
		TriggerRegisterPlayerChatEvent(t, Player(7), "", false);
		TriggerRegisterPlayerChatEvent(t, Player(8), "", false);
		TriggerRegisterPlayerChatEvent(t, Player(9), "", false);
		TriggerRegisterPlayerChatEvent(t, Player(10), "", false);
		TriggerRegisterPlayerChatEvent(t, Player(11), "", false);
		TriggerRegisterPlayerChatEvent(t, Player(12), "", false);
		TriggerRegisterPlayerChatEvent(t, Player(13), "", false);
		TriggerRegisterPlayerChatEvent(t, Player(14), "", false);
		TriggerRegisterPlayerChatEvent(t, Player(15), "", false);
		TriggerAddCondition(t, function() {
			player p = GetTriggerPlayer();
			integer CountSlow = LoadInteger(Hash, GetHandleId(p), 0);
			integer CountFast = LoadInteger(Hash, GetHandleId(p), 1);
			timer TimerSlow = LoadTimerHandle(Hash, GetHandleId(p), 2);
			timer TimerFast = LoadTimerHandle(Hash, GetHandleId(p), 3);
			dialog d;
			if(TimerSlow == null) { TimerSlow = CreateTimer(); }
			if(TimerFast == null) { TimerFast = CreateTimer(); }
			if(TimerGetRemaining(TimerSlow) < 5) { CountSlow = CountSlow + 1; }
				else if(SendDebug) { BJDebugMsg("Game on pause, anti-kick disabled!"); }
			if(TimerGetRemaining(TimerSlow) < 0.245) { CountFast = CountFast + 1; }
				else if(SendDebug) { BJDebugMsg("Game on pause, anti-kick disabled!"); }
			if(SendDebug) { BJDebugMsg("Slow " + I2S(CountSlow)); }
			if(SendDebug) { BJDebugMsg("Fast " + I2S(CountFast)); }
			SaveInteger(Hash, GetHandleId(p), 0, CountSlow);
			SaveInteger(Hash, GetHandleId(p), 1, CountFast);
			SaveTimerHandle(Hash, GetHandleId(p), 2, TimerSlow);
			SaveTimerHandle(Hash, GetHandleId(p), 3, TimerFast);
			TimerStart(TimerSlow, 5, true, function SlowSpamHandler);
			TimerStart(TimerFast, 0.245, true, function FastSpamHandler);
			SavePlayerHandle(Hash, GetHandleId(TimerSlow), 0, p);
			SavePlayerHandle(Hash, GetHandleId(TimerFast), 0, p);
			//Slow spam kick:
			if(CountSlow == 12) { DisplayTextToForce(GetForceOfPlayer(p), "|cffffa000Spam detected, slow down!"); }
			else if(CountSlow == 16) { DisplayTextToForce(GetForceOfPlayer(p), "|cffff0000You will be kicked for further spam!"); }
			else if(CountSlow >= 17) {
			DisplayTextToForce(GetForceOfPlayer(p), "|cffff0000Anti-spam has kicked you.");
			d = DialogCreate();
			DialogAddQuitButton(d, true, "Quit", 0);
			DialogSetMessage(d, "You have been removed from the game.");
			DialogDisplay(p, d, true);
			RemovePlayer(p, PLAYER_GAME_RESULT_DEFEAT);
			DestroyTimer(LoadTimerHandle(Hash, GetHandleId(p), 2));
			DestroyTimer(LoadTimerHandle(Hash, GetHandleId(p), 3));
			}
			//Fast spam kick:
			if(CountFast == 5) { DisplayTextToForce(GetForceOfPlayer(p), "|cffffa000Spam detected, slow down!"); }
			else if(CountFast == 6) { DisplayTextToForce(GetForceOfPlayer(p), "|cffff0000You will be kicked for further spam!"); }
			else if(CountFast >= 7) {
			DisplayTextToForce(GetForceOfPlayer(p), "|cffff0000Anti-spam has kicked you.");
			d = DialogCreate();
			DialogAddQuitButton(d, true, "Quit", 0);
			DialogSetMessage(d, "You have been removed from the game.");
			DialogDisplay(p, d, true);
			RemovePlayer(p, PLAYER_GAME_RESULT_DEFEAT);
			DestroyTimer(LoadTimerHandle(Hash, GetHandleId(p), 2));
			DestroyTimer(LoadTimerHandle(Hash, GetHandleId(p), 3));
			}
		p = null;
		d = null;
		});
		t = null;
	}
}
//! endzinc