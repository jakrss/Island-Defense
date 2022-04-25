//! zinc

library IslandDefenseGameMode requires IslandDefenseSystem, RevealMapForPlayer {
    public struct IslandDefenseGameMode extends GameMode  {
		module DefaultDefenderDeath;
		
        public static method onInit() {
            thistype this = thistype.allocate();
            Game.register(this);
        }
		
        public method name() -> string {
            return "Island Defense";
        }
        public method shortName() -> string {
            return "ID";
        }
        public method description() -> string {
            return "The normal Island Defense you know and love.";
        }
        
        public method isAvailable() -> boolean {
            // Count players, check that minimum are here.
            // 1v1?
            return true;
        }
		
		public method setWinningClass(integer class) {
			this.winnerClass = class;
		}
		
        private integer winnerClass = PlayerData.CLASS_NONE;
        public method winningClass() -> integer {
            return winnerClass;
        }
        
        public method setup() -> boolean {
            boolean continue = false;            
            real x = -384.0;
            real y = -512.0;
            SetMapFlag(MAP_LOCK_RESOURCE_TRADING, true); // Should prevent TradeHacks from working
            
            //Game.say("Game ID: " + I2S(Game.id()));
            
            // Players
            continue = Game.setupPlayers();
            if (!continue){
                Game.say("|cffff0000Players could not be set up.|r");
                return false;
            }
            
            SetCameraBounds(x, y, x, y, x, y, x, y);
            PanCameraToTimed(x, y, 0.0);
            
            if (GameSettings.getBool("ANTIHACK")) {
                GameTimer.newNamed(function(GameTimer t){
                    // Anti Maphack?
                    real x = -384.0;
                    real y = -512.0;
                    unit u = CreateUnit(Player(24), 'NOMH', x, y, 270.0);
                    UnitApplyTimedLife(u, 'BTLF', 1);
                    u = null;
                }, "AntiMH").start(0.5);
            }
			
			
			// Spoopiness
			// -fog 0 1000 8000 0.5 0.125 0.125 0.75
			// SetTerrainFogEx(0, 1000, 8000, 0.5, 0.125, 0.125, 0.75);
            
            // Start Game
            GameTimer.newNamed(function(GameTimer t){
                thistype this = t.data();
                // Check players
                if (!this.checkTitanStatus()) {
                    return;
                }
                
                SetCameraBoundsToRect(bj_mapInitialCameraBounds);
                Game.say("[|cff20bb20Game Starting. . .|r]");
                Game.setState(Game.STATE_STARTING);
                // Reset MMD
                MetaData.reset();
                PlaySoundBJ(gg_snd_Game_Start);
            
                SpeechSystem.initialize();
                PerksSystem.initialize();
                UnitManager.initialize();
                UnitManager.spawnSpellWell();
                UnitManager.spawnShops();
                //UnitManager.spawnCage();
				
                // Show Minimap + Reset all player upgrades!
                GameTimer.newNamed(function(GameTimer t){
                    PlayerDataArray list = PlayerData.all();
					player p = null;
                    integer i = 0;
                    for (0 <= i < list.size()){
						p = list[i].player();
                        SetFogStateRect(p, FOG_OF_WAR_VISIBLE, GetWorldBounds(), false);
						//Upgrades.resetAllUpgradesForPlayer(p, false);
                    }
                    list.destroy();
                }, "FlashMinimapTimer").start(0.0);
				
                SetTimeOfDay(bj_TOD_DUSK - 4.0); // 4 hours before dusk
                SetCreepCampFilterState(false);
                SuspendTimeOfDay(true);
                EnableOcclusion(true);
                
                CritterSystem.initialize();
                
                if (!RacePicker.initialize()) {
                    Game.say("Failed to initialize RacePicker");
                    return;
                }
                MultiboardUpdater.initialize();
            }, "GameInitStartDelay").start(GameSettings.getReal("GAME_INIT_START_DELAY")).setData(this);
            return true;
        }
        public method start() -> boolean {
            ExperienceSystem.initialize();
            PenaltyTimer.initialize();
            MercyLumber.initialize();
            MinionLumber.initialize();
            PeriodicTips.initialize();
            //TweakManager.printTweaks();
            PunishmentCentre.setAutoPunish(GameSettings.getBool("TITAN_AUTOPUNISH"));
            
            // TODO: Requires testing
            UnitManager.minionLevel = 2;
            GameTimer.newNamedPeriodic(function(GameTimer t){
                if (UnitManager.minionLevel >= 6) return;
                UnitManager.minionLevel = UnitManager.minionLevel + 1;
                Game.say("|cff99b4d1The Titan's wrath knows no bounds! Minions will now spawn at level: |r|cffff0000" + I2S(UnitManager.minionLevel) + "|cff99b4d1!");
            }, "MinionLevelTimer").start(GameSettings.getReal("MINION_SPAWN_LEVEL_TIME")); 
            
            SuspendTimeOfDay(false);
			
            return true;
        }
        
        public method pause(){
            // Pause Game
            if (GameSettings.getBool("GAME_PAUSE_TEST")){
                PauseGame(true);
            }
            else {
                // Pause Timers
                GameTimer.pauseTimers();
            
                // Pause units
                PauseAllUnitsBJ(true);
                TimerStart(NewTimer(), 0.40, true, function(){
                    timer t = GetExpiredTimer();
                    group g = CreateGroup();
                    boolexpr b = Filter(function() -> boolean {
                        return !IsUnitPaused(GetFilterUnit());
                    });
                    unit u = null;
                    
                    if (!Game.isState(Game.STATE_PAUSED)){
                        // Pausing over, time to clean up
                        ReleaseTimer(t);
                        t = null;
                        return;
                    }
                    
                    GroupEnumUnitsInRect(g, GetWorldBounds(), b);
                    u = FirstOfGroup(g);
                    while (u != null){
                        PauseUnit(u, true);
                    }
                    DestroyBoolExpr(b);
                    DestroyGroup(g);
                    b = null;
                    g = null;
                });
            }
        }
        
        public method resume(){
            if (GameSettings.getBool("GAME_PAUSE_TEST")){
                PauseGame(false);
            }
            else {
                // Resume Units
                PauseAllUnitsBJ(false);
                
                // Resume Timers
                GameTimer.resumeTimers();
            }
        }
        
        public method stop(){
            group g = GetUnitsInRectAll(GetWorldBounds());
            unit u = null;
            PlayerDataArray list = 0;
            integer i = 0;
            
            if (Game.isState(Game.STATE_FINISHED)){
                StopSound(gg_snd_Music_BuilderWin, false, true);
                StopSound(gg_snd_Music_TitanWin, false, true);
                ResetTerrainFog();
            }
            
            if (!Game.isState(Game.STATE_IDLE)){
                CritterSystem.terminate();
                TweakManager.terminate();
                PenaltyTimer.terminate();
                MercyLumber.terminate();
                SpeechSystem.terminate();
                // RacePicker can handle itself if it's called twice
                RacePicker.terminate();
                ExperienceSystem.terminate();
                // MultiboardUpdater can't, it doesn't have states
                MultiboardUpdater.terminate();
                //
                UnitManager.terminate();
                PerksSystem.terminate();
            }

            GameTimer.destroyTimers();

            u = FirstOfGroup(g);
            while (u != null){
                if (GetUnitTypeId(u) != 'e01B'){
                    RemoveUnit(u);
                } // Keep dummy units
                
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            ExecuteFunc("CreateAllUnits");

            EnumItemsInRect(GetWorldBounds(), null, function(){
                item i = GetEnumItem();
                if (GetItemTypeId(i) != 'wolg') {
                    RemoveItem(i);
                }
                i = null;
            });
            ExecuteFunc("CreateAllItems");
            list = PlayerData.all();
            for (0 <= i < list.size()){
                list[i].setGold(0);
                list[i].setWood(0);
            }
            list.destroy();
            list = 0;
        }
        
        public method restart(){
            Game.stop();
            Game.say("[|cffbb2020Game Restarting. . .|r]");
            TimerStart(NewTimer(), 1.00, false, function(){
                timer t = GetExpiredTimer();
                if (!Game.initialize()){
                    Game.say("|cffff0000An error has occured. The game could not be restarted.|r");
                }
                ReleaseTimer(t);
                t = null;
            });
        }
        
        public method finish(){
            Game.setState(Game.STATE_FINISHED);
        }
        
        public method checkVictory() -> boolean {
            if (Game.state() == Game.STATE_IDLE) return false;
            if (Game.state() == Game.STATE_STARTING) return false;
            if (Game.state() == Game.STATE_FINISHED) return false;
            if (TitanFinder.isActive()) return false;
            
            if ((PlayerData.countClass(PlayerData.CLASS_TITAN) == 0 &&
                 PlayerData.countClass(PlayerData.CLASS_MINION) == 0) ||
                (UnitManager.countTitans() == 0 &&
                 UnitManager.countMinions() == 0)){
                // No Titans / minions left!
                if (GameSettings.getBool("VICTORY_DISABLED")){
                    Game.say("|cff99b4d1The game should of ended with the defenders winning, but game victory is disabled.|r");
                }
                else {
					if (this.winningClass() == PlayerData.CLASS_NONE) this.winnerClass = PlayerData.CLASS_DEFENDER;
                    Game.setState(Game.STATE_FINISHED);
                    Game.say("|cff99b4d1The defenders have slain the titan and his minions, the island is saved!|r" );
                
                    PlaySoundBJ(gg_snd_Music_BuilderWin);
                }
            }
            else if (PlayerData.countClass(PlayerData.CLASS_DEFENDER) == 0){
                // No defenders left!
                if (GameSettings.getBool("VICTORY_DISABLED")){
                    Game.say("|cff99b4d1The game should of ended with the titan winning, but game victory is disabled.|r");
                }
                else {
                    if (this.winningClass() == PlayerData.CLASS_NONE) this.winnerClass = PlayerData.CLASS_TITAN;
                    Game.setState(Game.STATE_FINISHED);
                    Game.say("|cff99b4d1The titan and his minions have slain all the defenders, the island is doomed!|r" );
                    SetTerrainFogEx(0, 1000, 8000, 0, 0, 0, 1);
                    
                    PlaySoundBJ(gg_snd_Music_TitanWin);
                }
            }
            if (Game.state() != Game.STATE_FINISHED) return false;
            Game.say("|cff99b4d1Thank you for playing this version of Island Defense! " +
                         "Brought to you by |cff3399ffRemixer|cff99b4d1, |cff3399ffIAmDragon|cff99b4d1 and |cff3399ffKappa|cff99b4d1.|r");
             
             // Show Map
            FogEnable(false);
             
            // Finalize MMD and synchronize.
			MetaData.finalize();
            
            // Start game over timer, forcing players to leave.
            Game.say("|cffbb2020The game will end shortly.|r");
            GameTimer.newNamed(function(GameTimer t){
                Game.endGame();
            }, "EndGameDelay").start(GameSettings.getReal("GAME_END_TIMER"));
            return true;
        }
        
        public method playerResult(PlayerData p) -> integer {
            integer result = 0;
            if (GameSettings.getBool("DEBUG")) {
                result = -1;
            }
            else {
		if (p.initialClass() == this.winningClass()) {
                    result = 1;
                }
                else {
                    result = 0;
                }
            }
            
            return result;
        }
        
        public method endGame(){
            PlayerDataArray list = 0;
            PlayerData p = 0;
            integer i = 0;
            
            list = PlayerData.all();
            for (0 <= i < list.size()){
                p = list[i];
                if (p.initialClass() == this.winnerClass){
                    RemovePlayer(p.player(), PLAYER_GAME_RESULT_VICTORY);
                }
                else {
                    RemovePlayer(p.player(), PLAYER_GAME_RESULT_DEFEAT);
                }
            }
            list.destroy();
            
            EndGame(true);
        }
        
        public method checkTitanStatus() -> boolean {
            // Check Titan status
            if (PlayerData.countClass(PlayerData.CLASS_TITAN) == 0){
                // Dammit!
                Game.say("|cffff0000Could not load a titan.|r");
                
                // Required as to not create an infinite loop / crash
                // Because if we just called the function and it was instant 
                // (ie. choose a random defender then return) it would call
                // Game.start() even though Game.start() was still running
                GameTimer.newNamed(function(GameTimer t){
                    TitanFinder.findTitan();
                }, "FindTitanLoopDelay").start(0.0);
                
                return false;
            }
            return true;
        }
        
        public method loadFakePlayers() {
            integer i = 0;
            player p = null;
            PlayerData q = 0;
            for (0 <= i < 11){
                p = Player(i);
                // Should we register players even if they aren't playing (ie. Computers)?
                if (!Game.ignorePlayers[i] && !PlayerData.has(p)){
                    if (((GetPlayerController(p) != MAP_CONTROL_USER) ||
                        (GetPlayerSlotState(p) != PLAYER_SLOT_STATE_PLAYING)) &&
                        (GetPlayerController(p) == MAP_CONTROL_COMPUTER || GameSettings.getBool("FORCE_FAKE_PLAYERS"))) {
                        q = PlayerData.register(p);
                        q.setFake(true);
                    }
                }
            }
            p = null;
        }
        
        public method setupPlayers() -> boolean {
            integer count = 0;
            integer i = 0;
            PlayerDataArray list = 0;
            PlayerData p = 0;
            
            count = PlayerData.countReal();

			if ((count == 2) && (GetPlayerController(Player(11)) == MAP_CONTROL_USER) && (GetPlayerSlotState(Player(11)) == PLAYER_SLOT_STATE_PLAYING)){
				count = count - 1;
            }
            
            // No players, do nothing?
            if (count == 0){
                
                Game.say("|cffff0000No real players detected...|r");
                return false;
            }
            // One player, or debug mode.
            //if(GameSettings.getBool("FORCE_DEBUG_MODE")) BJDebugMsg("Player Count: " + I2S(count) + ", Force Debug: true");
            //else BJDebugMsg("Player Count: " + I2S(count) + ", Force Debug: false");
            
            if (count == 1 || GameSettings.getBool("FORCE_DEBUG_MODE")){
                // Only one player, so debug mode!
                // TODO: Give the option to the player whether they want Builder or Titan?
                Game.say("|cffbb2020Debug Mode|r");
                GameSettings.loadDebugSettings();
                // Reload with fake players
                if (PlayerData.count() == 1 && GameSettings.getBool("FORCE_FAKE_PLAYERS_WHEN_ALONE")){
                    Game.say("|cffbb2020Forcing fake players.|r");
                    GameSettings.setBool("FORCE_FAKE_PLAYERS", true);
                }
				
				if (GameSettings.getBool("FORCE_FAKE_PLAYERS")) {
					// Load fakeplayers then reinit TweakManager
                    this.loadFakePlayers();
					TweakManager.terminate();
					TweakManager.initialize();
					
					// This is the culprit!
					//Upgrades.terminate();
					//Upgrades.initialize();
                    
                    Game.clearPlayerClasses();
                }
                GameSettings.setBool("DEBUG", true);
            } else {
                //Game.setMode(Game.GAME_STARTED);
                //BJDebugMsg("Supposed to be normal game");
            }
        
            // Load player classes.
            list = PlayerData.all();
            for (0 <= i < list.size()){
                p = list.at(i);
                if (TitanFinder.forceAsTitan[p.id()]){
                    p.setInitialClass(PlayerData.CLASS_TITAN);
                }
                else if (p.id() >= GameSettings.getInt("PLAYER_DEFENDER_LOWERBOUND") &&
                    p.id() <= GameSettings.getInt("PLAYER_DEFENDER_UPPERBOUND")){
                    p.setInitialClass(PlayerData.CLASS_DEFENDER);
                }
                else if (p.id() >= GameSettings.getInt("PLAYER_TITAN_LOWERBOUND") &&
                         p.id() <= GameSettings.getInt("PLAYER_TITAN_UPPERBOUND")){
                    p.setInitialClass(PlayerData.CLASS_TITAN);
                } else if (p.id() >= GameSettings.getInt("PLAYER_OBSERVER_LOWERBOUND") && p.id() <= GameSettings.getInt("PLAYER_OBSERVER_UPPERBOUND")) {
                    p.setInitialClass(PlayerData.CLASS_OBSERVER);
		}
                Game.onPlayerJoin(p);
            }
            list.destroy();
            
            if (!this.checkTitanStatus()) {
                return false;
            }
            
            if (!GameSettings.getBool("DEBUG")){
                Game.say("|cff99b4d1Visit |cff3399ffIslandDefense.com|cff99b4d1.|cff99b4d1 Loaded|r "
                                + I2S(PlayerData.countClass(PlayerData.CLASS_TITAN)) + "|cff99b4d1 titan/s and |r"
                                + I2S(PlayerData.countClass(PlayerData.CLASS_DEFENDER)) + "|cff99b4d1 defenders.|r"
				+ I2S(PlayerData.countClass(PlayerData.CLASS_OBSERVER)) + "|cff99b4d1 observers.|r");
            }
            else {
                Game.say("|cffbb2020A debug Island Defense game has been loaded.|r");
                Game.say("|cff99b4d1Visit |cff3399ffIslandDefense.com|cff99b4d1.|cff99b4d1 Loaded "
                                + I2S(PlayerData.countClass(PlayerData.CLASS_TITAN)) + "|cff99b4d1 titan/s and |r"
                                + I2S(PlayerData.countClass(PlayerData.CLASS_DEFENDER)) + "|cff99b4d1 defenders.|r"
				+ I2S(PlayerData.countClass(PlayerData.CLASS_OBSERVER)) + "|cff99b4d1 observers.|r");
                // TODO
                // More info on commands
                // and cheatpack activation
                GameSettings.setBool("VICTORY_DISABLED", true);
                Game.activateCheats();
            }
            
            Game.say("|r" + I2S(DefenderRace.count()) + " |cff99b4d1Defender races and |r" +
                         "|r" + I2S(TitanRace.count()) + " |cff99b4d1Titan races have been loaded.|r");

            PlayerData.forceAlliances();
            
            return true;
        }
    }
}

//! endzinc