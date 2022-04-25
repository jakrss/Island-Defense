//! zinc

library TitanFinder requires IslandDefenseSystem, Dialog, UpgradeSystem {
    public struct TitanFinder {
        public static constant integer METHOD_RANDOM = 0;
        public static constant integer METHOD_DIALOG = 1;
        public static constant integer METHOD_COMMAND = 2;
        private static integer mMethod = METHOD_COMMAND;
        
        public static method findMethod() -> integer {
            return thistype.mMethod;
        }
        
        public static method isMethod(integer i) -> boolean {
            return thistype.findMethod() == i;
        }
        
        private static boolean active = false;
        public static method isActive() -> boolean {
            return thistype.active;
        }
        
        private static method setActive(boolean b){
            thistype.active = b;
        }
        
        static PlayerData newPlayer = 0;
        static PlayerData oldPlayer = 0;
        
        static timer timeoutTimer = null; // Use normal timer since GameTimer's are disabled.
        
        public static boolean forceAsTitan[12];
        
        private static method findRandomDefender() -> PlayerData {
            integer i = 0;
            integer count = 0;
            PlayerDataArray list = 0;
            PlayerData options[];
            
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            list.merge(PlayerData.withClass(PlayerData.CLASS_OBSERVER));
            
            for (0 <= i < list.size()){
                options[count] = list[i];
                count = count + 1;
            }
            list.destroy();
            return options[GetRandomInt(0, count - 1)];
        }
        
        private static Dialog queryDialog = 0;
        private static method showDialog(){
            if (queryDialog != 0){
                queryDialog.destroy();
                queryDialog = 0;
            }
            queryDialog = Dialog.create();
            queryDialog.SetMessage("Titan?");
            queryDialog.AddButton("No", HK_N);
            queryDialog.AddButton("Yes", HK_Y);
            
            queryDialog.AddAction(function(){
                Dialog d = Dialog.Get();
                player p = GetTriggerPlayer();
                integer i = 0;
                
                if (Dialog.Get() != thistype.queryDialog ||
                    thistype.queryDialog == 0){
                    return;
                }
                
                i = d.GetResult();
                if (i == HK_Y){
                    d.HideAll();
                    d.destroy();
                    thistype.queryDialog = 0;
                    newPlayer = PlayerData.get(p);
                    thistype.finish();
                }
            });
            
            queryDialog.ShowAll();
        }
        
        public static method foundNewTitan(PlayerData p){
            if (!thistype.isActive()) return;
            thistype.newPlayer = p;
            thistype.finish();
        }
        
        private static method beginCommand(){
            Game.say("|cff00bfffType |r-titan|cff00bfff to become the new Titan.");
        }
        
        private static method timeout(){
            timer t = GetExpiredTimer();
            integer id = GetTimerData(t);
            ReleaseTimer(t);
            t = null;
            if (Game.id() != id) return;
            thistype.timeoutTimer = null;
            
            if (thistype.queryDialog != 0){
                queryDialog.HideAll();
                queryDialog.destroy();
                queryDialog = 0;
            }
            
            if (GameSettings.getBool("TITAN_FINDER_FORCE_NEW")){
                Game.say("|cffff0000No one chose to become the new Titan, picking a random player...|r");
                thistype.newPlayer = thistype.findRandomDefender();
                thistype.finish();
            }
            else {
                Game.say("|cffff0000No one chose to become the new Titan, the game will now finish.|r");
                thistype.newPlayer = 0;
                thistype.finish();
            }
            
            
        }
        
        public static method findTitan(){
            thistype.setActive(true);
            thistype.newPlayer = 0;
            
            if (thistype.isMethod(thistype.METHOD_RANDOM)){
                thistype.newPlayer = thistype.findRandomDefender();
                thistype.finish();
            }
            else if (thistype.isMethod(thistype.METHOD_DIALOG)){
                thistype.showDialog();
            }
            else if (thistype.isMethod(thistype.METHOD_COMMAND)){
                thistype.beginCommand();
            }
            
            thistype.timeoutTimer = NewTimer();
            SetTimerData(thistype.timeoutTimer, Game.id());
            
            if (GameSettings.getBool("TITAN_FINDER_FORCE_NEW")){
                Game.say("|cffff0000If no one chooses to become the new Titan within 15 seconds, a player will be selected at random instead.|r");
            }
            else {
                Game.say("|cffff0000If no one chooses to become the new Titan within 15 seconds, the game will end.");
            }
            
            TimerStart(thistype.timeoutTimer, 15.0, false, static method thistype.timeout);
        }
        
        public static method findNewTitan(PlayerData last){
            Game.pause();
            thistype.oldPlayer = last;
            
            thistype.findTitan();
        }
        
        private static method finish(){
            if (!thistype.isActive()) return;
            thistype.setActive(false);
            // Okay, we have our titan so time to resume the game!
            if (thistype.timeoutTimer != null){
                ReleaseTimer(thistype.timeoutTimer);
                thistype.timeoutTimer = null;
            }
            
            if (Game.state() == Game.STATE_PAUSED) Game.resume();
            if (thistype.newPlayer != 0){
                Game.say(thistype.newPlayer.nameColored() + "|cff00bfff has been chosen as the new titan!|r");
                if (Game.state() == Game.STATE_IDLE){
                    thistype.forceAsTitan[thistype.newPlayer.id()] = true;
                    Game.restart();
                }
                else if (Game.state() == Game.STATE_STARTING){
                    if (RacePicker.state() == RacePicker.STATE_RUNNING){
                        UnitManager.removePlayerUnits(thistype.newPlayer);
                        thistype.newPlayer.setInitialClass(PlayerData.CLASS_TITAN);
                        thistype.newPlayer.setRace(NullRace.instance());
                        thistype.newPlayer.setGold(thistype.oldPlayer.gold());
                        thistype.newPlayer.setWood(thistype.oldPlayer.wood());
                        
                        // Resets their initial pick configuration
                        thistype.newPlayer.setRace(NullRace.instance());
                        PlayerDataPick[thistype.oldPlayer].setRandoming(false);
                        PlayerDataPick[thistype.newPlayer].setRandoming(false);
                        RacePicker.pickMode().setupPlayer(thistype.newPlayer);
						
						// Set old Titan to always lose
                        thistype.oldPlayer.setInitialClass(PlayerData.CLASS_NONE);
						
						//Upgrades.swapPlayerUpgradeTables(thistype.oldPlayer.player(), thistype.newPlayer.player());
                        
                        PlayerDataPick[thistype.newPlayer].setCanPick(PlayerDataPick[thistype.oldPlayer].canPick());
                    }
                    else if (RacePicker.state() == RacePicker.STATE_FINISHED){
                        // Error
                    }
                    else {
                        // Voting
                        thistype.newPlayer.setInitialClass(PlayerData.CLASS_TITAN);
						// Set old Titan to always lose
                        thistype.oldPlayer.setInitialClass(PlayerData.CLASS_NONE);
                        
                        // Fix for 4.0.0.0099 - Randoming persists when using -titan
                        if (PlayerDataPick.initialized()){
                            PlayerDataPick[thistype.newPlayer].setRandoming(false);
                        }
                    }
                    thistype.oldPlayer.left();
                }
                else if (Game.state() == Game.STATE_STARTED){
                    if (thistype.oldPlayer == 0) {
                        Game.say("|cffff0000ERROR - The old titan could not be found. This function will now fail. Please report this.|r");
                    }
                    UnitManager.removePlayerUnits(thistype.newPlayer);
                    thistype.newPlayer.setClass(PlayerData.CLASS_TITAN);
                    thistype.newPlayer.setRace(thistype.oldPlayer.race());
                    thistype.newPlayer.setGold(thistype.oldPlayer.gold());
                    thistype.newPlayer.setWood(thistype.oldPlayer.wood());
                    UnitManager.givePlayerUnitsTo(thistype.oldPlayer, thistype.newPlayer);
                    SwapUpgrades(GetPlayerId(thistype.newPlayer.player()), GetPlayerId(thistype.oldPlayer.player()));
                    UnitManager.setWellOwner(thistype.newPlayer.player());
                    PunishmentCentre.update();
					
                    thistype.oldPlayer.left();
                }
                thistype.oldPlayer = 0;
                thistype.newPlayer = 0;
            }
            else {
                // No new player, but finish() called... end the game
                thistype.oldPlayer.left();
                // Force "started" state
                Game.setState(Game.STATE_STARTED);
                Game.checkVictory();
            }
        }
    }
}

//! endzinc