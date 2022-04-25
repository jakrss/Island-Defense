//! zinc

library LeaveEvent requires IslandDefenseSystem {
    private function beginDefenderLeaveGrace(PlayerData p) {
        // Set them to be leaving
        p.leaving();
        
        // Give defenders control
        PlayerData.forceAlliances();
        
        // Has left the game, 30 seconds grace
        GameTimer.new(function(GameTimer t){
            PlayerData p = t.data();
            // Exit out if they're already gone
            if (!p.isLeaving() || p.hasLeft()) return;
			if (GameSettings.getBool("NEUTRALIZE_STRUCTURES")) {
				if (GameSettings.getBool("NEUTRALIZE_STRUCTURES_DECAY")) {
					Game.say("|cff00bfff30 seconds until |r" + p.nameColored() + "|cff00bfff's units are removed.  Their structures will remain for an additional " + 
							 I2S(R2I(GameSettings.getReal("NEUTRALIZE_STRUCTURES_DECAY_TIME"))) + " seconds.|r");
				}
				else {
					Game.say("|cff00bfff30 seconds until |r" + p.nameColored() + "|cff00bfff's units are removed.  Their structures will remain until killed.|r");
				}
			}
			else {
				Game.say("|cff00bfff30 seconds until |r" + p.nameColored() + "|cff00bfff's units are removed.|r");
			}
            GameTimer.new(function(GameTimer t){
				PlayerDataArray list = 0;
				integer i = 0;
				integer bonus = 0;
                PlayerData p = t.data();
				PlayerData q = 0;
                // Exit out if they're already gone
                if (!p.isLeaving() || p.hasLeft()) return;
				if (GameSettings.getBool("NEUTRALIZE_STRUCTURES")) {
					if (GameSettings.getBool("NEUTRALIZE_STRUCTURES_DECAY")) {
						Game.say(p.nameColored() + "|cff00bfff's units have been removed. Their structures will remain for an additional " + I2S(R2I(GameSettings.getReal("NEUTRALIZE_STRUCTURES_DECAY_TIME"))) + " seconds.|r");
					}
					else {
						Game.say(p.nameColored() + "|cff00bfff's units have been removed. Their structures will remain until killed.|r");
					}
				}
				else {
					Game.say(p.nameColored() + "|cff00bfff's units have been removed.|r");
				}
				// Grant the Titan an extra bonus!
				if (GameSettings.getBool("TITAN_BONUS_ON_DEFENDER_LEAVE")) {
					list = PlayerData.withClass(PlayerData.CLASS_TITAN);
					bonus = GameSettings.getInt("TITAN_BONUS_ON_DEFENDER_LEAVE_GOLD");
					for (0 <= i < list.size()){
						q = list[i];
                        if (q != 0){
                            q.setGold(q.gold() + bonus);
                        }
                    }
					list.destroy();
					list = 0;
				}
				
                UnitManager.neutralizePlayerUnits(p);
                p.left();
				// Fake the fact that the Defender has been "killed" for the sake of the missing players factor
				GameSettings.setInt("KILLED_DEFENDERS_COUNT", GameSettings.getInt("KILLED_DEFENDERS_COUNT") + 1);
				
            }).start(30.00).setData(p);
        }).start(30.00).setData(p);
    }
    
    public function onPlayerLeave(PlayerData p){
        PlayerData q = 0;
        PlayerDataArray list = 0;
        integer i = 0;
        if (p == 0) {
            Game.say("|cffff0000Error - A player left that we didn't have player data for. Please report this.|r");
            //Game.say("Beginning player dump...");
            return;
        }
        
        Game.say(p.nameClassColored() + "|cff00bfff has left the game.|r");
        p.leaving();
        
        if (Game.state() == Game.STATE_IDLE){
            // We can technically ignore this since player data will be initialized
            // when the game is started
            p.left();
            return;
        }
        if (Game.state() == Game.STATE_STARTING ||
            (Game.state() == Game.STATE_PAUSED &&
             Game.pausedState() == Game.STATE_STARTING)){
            // Handle leaving players during the initialization (titan is especially worrisome)
            if (p.class() == PlayerData.CLASS_TITAN){
                // We can't begin our game without a titan!
                if (PlayerData.countClass(PlayerData.CLASS_TITAN) == 1){
                    Game.say("|cff00bfffThe game cannot continue with a Titan. " +
                             "A new one will now be selected, and the game will resume.|r");
                    p.left();
                    TitanFinder.findNewTitan(p);
                }
            }
            else if (p.class() == PlayerData.CLASS_DEFENDER ||
                     p.class() == PlayerData.CLASS_OBSERVER){
                if (PlayerDataPick.initialized() && PlayerDataPick[p].hasPicked()) {
                    beginDefenderLeaveGrace(p);
                }
                else {
                    p.left();
                }
            }
        }
        if (Game.state() == Game.STATE_STARTED ||
            (Game.state() == Game.STATE_PAUSED &&
            Game.pausedState() == Game.STATE_STARTED)){
            // Handle leaving players during the game
            if (p.class() == PlayerData.CLASS_TITAN){
                if (PlayerData.countClass(PlayerData.CLASS_TITAN) == 1){
					// MMD - the titan left during the game, so it's technically now over as far as stats recording is concerned
					if (Game.isMode("ID")) {
						Game.say("|cff00bfffSince the original Titan has left, the Defenders have won! Feel free to continue playing the game.|r");
						IslandDefenseGameMode(Game.mode()).setWinningClass(PlayerData.CLASS_DEFENDER);
						MetaData.finalize();
					}
				
                    if (PlayerData.countClass(PlayerData.CLASS_MINION) == 0){
                        // He was the last titan, we have to find a new one!
                        //p.left();
                        TitanFinder.findNewTitan(p);
                    }
                    else {
                        // We have a minion to promote to titan
                        list = PlayerData.withClass(PlayerData.CLASS_MINION);
                        q = list.at(i);
                        q.setClass(PlayerData.CLASS_TITAN);
                        q.setGold(p.gold() + q.gold());
                        q.setWood(p.wood() + q.wood());
                        UnitManager.givePlayerUnitsTo(p, q);
                        UnitManager.setWellOwner(q.player());
                        PunishmentCentre.update();
                        p.left();
                    }
                }
                else {
                    list = PlayerData.withClass(PlayerData.CLASS_TITAN);
                    for (0 <= i < list.size()){
                        if (list[i] != p){
                            UnitManager.givePlayerUnitsTo(p, list[i]);
                            UnitManager.setWellOwner(list[i].player());
                            PunishmentCentre.update();
                            break;
                        }
                    }
                    list.destroy();
                    list = 0;
                    p.left();
                }
            }
            else if (p.class() == PlayerData.CLASS_MINION){
                PunishmentCentre.update();
                
                q = 0;
                list = PlayerData.withClass(PlayerData.CLASS_TITAN);
                for (0 <= i < list.size()){
                    q = list.at(i);
                    if (q.race() == p.race()){
                        break;
                    }
                }
                list.destroy();
                if (q != 0){
                    UnitManager.givePlayerUnitsTo(p, q);
					q.setGold(p.gold() + q.gold());
					q.setWood(p.wood() + q.wood());
				}
                else {
                    // Error
                    Game.say("|cffff0000No titans left.|r");
                }
                p.left();
            }
            else if (p.class() == PlayerData.CLASS_DEFENDER){
                beginDefenderLeaveGrace(p);
            }
            else if (p.class() == PlayerData.CLASS_OBSERVER) {
                p.left();
            }
        }
        if (Game.state() == Game.STATE_FINISHED ||
            (Game.state() == Game.STATE_PAUSED &&
            Game.pausedState() == Game.STATE_FINISHED)){
            // Do not flag them as left, since the MMD system will kick in as the game ends.
            if (p.class() == PlayerData.CLASS_TITAN){
                //p.left();
            }
            
            if (p.class() == PlayerData.CLASS_DEFENDER){
                //p.left();
            }
        }
    }
    
    public function onPlayerLeaveBegin(player p) {
        if (IsPlayerObserver(p)) {
            Game.say(GetPlayerActualName(p) + "|cff00bfff (Observer) has left the game.|r");
            return;
        }
        onPlayerLeave(PlayerData.get(p));
    }

    private function onInit(){
        trigger t = CreateTrigger();
        integer i = 0;
        for (0 <= i < 12){
            TriggerRegisterPlayerEvent(t, Player(i), EVENT_PLAYER_LEAVE);
        }
        TriggerAddAction(t, function(){
            player p = GetTriggerPlayer();
            onPlayerLeaveBegin(p);
            p = null;
        });
        t = null;

        Command["-frestart"].register(function(Args a){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
			if (!GameSettings.getBool("DEBUG") && p.name() != GameSettings.getStr("EDITOR")) return;
            Game.restart();
        });
        
        Command["-ftest"].register(function(Args a){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            if (!GameSettings.getBool("DEBUG")) return;
            p.setGold(p.gold() + 1800);
            p.setWood(p.wood() + 38000);
            p.say("Testing resources!");
        });
        
        Command["-ftkick"].register(function(Args a){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            PlayerDataArray list = 0;
            integer i = 0;
            if (!GameSettings.getBool("DEBUG")) return;
            list = PlayerData.withClass(PlayerData.CLASS_TITAN);
            for (0 <= i < list.size()){
                if (list[i] != p){
                    RemovePlayer(list.at(i).player(), PLAYER_GAME_RESULT_DEFEAT);
                    break;
                }
            }
            list.destroy();
        });
		
		Command["-fdkick"].register(function(Args a){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            PlayerDataArray list = 0;
            integer i = 0;
            if (!GameSettings.getBool("DEBUG")) return;
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            for (0 <= i < list.size()){
                if (list[i] != p){
                    RemovePlayer(list.at(i).player(), PLAYER_GAME_RESULT_DEFEAT);
                    break;
                }
            }
            list.destroy();
        });
    }
}

//! endzinc

// Really dumb, can't use hooks in Zinc...
library LeaveHook requires LeaveEvent
    public function onPlayerRemove takes player p, playergameresult gameresult returns nothing
        call onPlayerLeaveBegin(p)
    endfunction
    
    hook RemovePlayer onPlayerRemove
endlibrary