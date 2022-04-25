//! textmacro SETUP_DEFAULT_SETTINGS
    GameSettings.setStr ("EDITOR", "IAmDragon");
    
    // Pickmode settings
	GameSettings.setStr ("GAME_MODE", "ID");
    GameSettings.setStr ("PICKMODE_DEFAULT", "UP");         // AP
    GameSettings.setReal("PICKMODE_VOTE_TIME", 2.0); // 15
	GameSettings.setReal("PICKMODE_DEFAULT_START_DELAY", 2.0);	//10
    GameSettings.setBool("PICKMODE_VOTE_ENABLED", true);
    GameSettings.setBool("PICKMODE_VOTE_REQUIRES_TITAN", true);
    
    GameSettings.setInt("PICKMODE_RACE_BAN_MAX", 4);
    GameSettings.setInt("PICKMODE_RACE_BAN_MAX_TITANS", 2);
    
    GameSettings.setReal("GAME_INIT_START_DELAY", 5.0);	//5
    
    GameSettings.setBool("STARTGAME_MESSAGE_ENABLED", false);
    GameSettings.setStr ("STARTGAME_MESSAGE_TEXT", "Welcome to Island Defense!\nJoin the discussion and get the latest version in the discord\nhttps://discord.gg/aHghEf3\nThe current version is 4.1.0");
    GameSettings.setStr ("STARTGAME_MESSAGE_FROM", "|c00FF0000IAmDragon|r");
    GameSettings.setInt ("STARTGAME_MESSAGE_FROM_ID", 'n020');
    GameSettings.setReal("STARTGAME_MESSAGE_TIME", 10.00);
	
	
	// Leaving Builder Bonus
    GameSettings.setBool("TITAN_BONUS_ON_DEFENDER_LEAVE", false);
    GameSettings.setInt ("TITAN_BONUS_ON_DEFENDER_LEAVE_GOLD", 10);
    GameSettings.setBool("NEUTRALIZE_STRUCTURES", true);
    GameSettings.setBool("NEUTRALIZE_STRUCTURES_DECAY", true);
    GameSettings.setReal("NEUTRALIZE_STRUCTURES_DECAY_TIME", 120.0);
	
    // Lightning Effects (Desync Test)
    GameSettings.setBool("LIGHTNING_EFFECTS_ENABLED", false);
    
    // Camera Bounds test
    GameSettings.setBool("RESTRICT_CAMERA_BOUNDS", true);
    
    //Turn on Basing System
    GameSettings.setBool("BASING_SYSTEM_ACTIVATED", false);
    
    // Maphack test
    GameSettings.setBool("ANTIHACK", false);
    
    // Whether debug mode should be forced.
    GameSettings.setBool("FORCE_DEBUG_MODE", false);
    GameSettings.setBool("DEBUG", false);
    
    // Time between Defenders being able to pick, and the Titan being able to pick.
    GameSettings.setReal("TITAN_SPAWN_GRACE_TIME", 55.0);
    
    // Whether or not autopunish should be enabled by default 
    GameSettings.setBool("TITAN_AUTOPUNISH", false);
    
    // Should afk players be removed when the Titan spawns?
    GameSettings.setBool("PICKMODE_REMOVE_AFK", true);
    
    // Game victory / end.
    GameSettings.setBool("VICTORY_DISABLED", false);
    GameSettings.setReal("GAME_END_TIMER", 30.0);
    
    // Is the W3MMD library activated? If true stats will be sent.
    GameSettings.setBool("MMD_ENABLED", true);
    GameSettings.setBool("MMD_EXTRAS_ENABLED", false);
    
    // Fake player settings.
    GameSettings.setBool("FORCE_FAKE_PLAYERS", true);
    GameSettings.setBool("FAKE_PLAYERS_AUTOPICK", true);		//Originally True. Changed for testing.
    GameSettings.setBool("FORCE_FAKE_PLAYERS_WHEN_ALONE", true);	//Setting this to true causes the Titan to be missing.
    
    // Experience Manipulation
    GameSettings.setReal("TITAN_EXP_GLOBAL_FACTOR", 1.0);
	GameSettings.setReal("TITAN_EXP_SHARE_FACTOR", 0.75);
    GameSettings.setBool("TITAN_EXP_GLOBAL_FACTOR_DOUBLED", false);
    GameSettings.setBool("TITAN_EXP_REDUCTION_ENABLED", true);
    GameSettings.setReal("TITAN_EXP_MISSING_PLAYER_FACTOR", 0.06);
    GameSettings.setReal("TITAN_EXP_NEUTRAL_FACTOR", 0.5);
    GameSettings.setReal("DEFENDER_EXP_RATE_TIME", 1.0);
    
    // Titan start settings.
    GameSettings.setInt ("TITAN_START_LEVEL", 2);
    GameSettings.setInt ("TITAN_START_GOLD", 150);
    GameSettings.setInt ("TITAN_RANDOM_GOLD_BONUS", 0);
    GameSettings.setInt ("TITAN_START_WOOD", 250);
    GameSettings.setInt ("TITAN_RANDOM_WOOD_BONUS", 250);
    
    // Whether or not to force a new Titan if no one volunteers. If false, the game will end instead.
    GameSettings.setBool("TITAN_FINDER_FORCE_NEW", false);
    
    // Minion Grace Settings (invul, can't attack, silenced)
    GameSettings.setBool("MINION_ALLOW_GRACE", true);
    GameSettings.setReal("MINION_GRACE_TIME", 5.0);
    GameSettings.setBool("MINION_FORCE_OBS", false);
    
    GameSettings.setBool("MINION_SPAWN_ALLOW_GRACE", true);
    GameSettings.setReal("MINION_SPAWN_GRACE_TIME", 180.0); // 3 minutes
    GameSettings.setReal("MINION_SPAWN_LEVEL_TIME", 450.0); // many minutes
    
    // Enabled in 0082, appears to use up in-game user pauses. 
    GameSettings.setBool("GAME_PAUSE_TEST", false); 
    
    // The range of players that will be set to become Defenders.
    GameSettings.setInt ("PLAYER_DEFENDER_LOWERBOUND", 0);
    GameSettings.setInt ("PLAYER_DEFENDER_UPPERBOUND", 9);
    
    // The range of players that will be set to become Titans, if they are not already a Defender.
    GameSettings.setInt ("PLAYER_TITAN_LOWERBOUND", 10);
    GameSettings.setInt ("PLAYER_TITAN_UPPERBOUND", 10);

    // The range of players that will be set to become observers of the Defenders (they can take over if someone get's DC'd or just watch and learn)
    GameSettings.setInt ("PLAYER_OBSERVER_LOWERBOUND", 11);
    GameSettings.setInt ("PLAYER_OBSERVER_UPPERBOUND", 11);
    
    //Max number of people in-game
    GameSettings.setInt ("MAX_PLAYERS", 11);
    
    // Upkeep
    GameSettings.setBool("UPKEEP_MODE", false);
    
    GameSettings.setBool("TITAN_AUTOATTACK_ON", false);
	
	// Gold Stolen
    GameSettings.setInt ("TITAN_MOUND_GOLD_STOLEN", 0);
    
    // Debug Overrides
    debug {
        loadDebugSettings();
    }
//! endtextmacro

//! zinc

library GameSettings requires Table {
    private struct Setting {
        public string s;
        
        public static method create(string s) -> thistype {
            thistype this = thistype.allocate();
            this.s = s;
            return this;
        }
    }
    public struct GameSettings {
        public static StringTable settings = 0;

        public static method operator[] (string s) -> string {
            Setting setting = 0;
            if (thistype.settings.exists(s)){
                setting = thistype.settings[s];
                return setting.s;
            }
            return "";
        }
        
        public static method operator[]= (string s, string value){
            Setting setting = 0;
            if (thistype.settings.exists(s)){
                setting = thistype.settings[s];
            }
            else {
                setting = Setting.create(s);
            }
            setting.s = value;
            thistype.settings[s] = setting;
        }
        
        public static method getBool(string s) -> boolean {
            return (StringCase(thistype[s], false) == "true" ||
                    S2I(thistype[s]) >= 1);
        }
        public static method setBool(string s, boolean b) {
            if (b){
                thistype[s] = "true";
                return;
            }
            thistype[s] = "false";
        }
        public static method getStr(string s) -> string {
            return thistype[s];
        }
        public static method setStr(string s, string d){
            thistype[s] = d;
        }
        public static method getReal(string s) -> real {
            return S2R(thistype[s]);
        }
        public static method setReal(string s, real r){
            thistype[s] = R2S(r);
        }
        public static method getInt(string s) -> integer {
            return S2I(thistype[s]);
        }
        public static method setInt(string s, integer i){
            thistype[s] = I2S(i);
        }
        
        public static method onInit(){
            thistype.settings = StringTable.create();
            

            //! runtextmacro SETUP_DEFAULT_SETTINGS()
            
			// Commented this out for now, as we don't use it and it makes the map less portable
            ////! import "code/settings.zn"
            
            // Finally, check HCL
        }
        
        public static method loadDebugSettings() {
            GameSettings.setBool("PICKMODE_VOTE_ENABLED", false); // Skip voting
            GameSettings.setBool("STARTGAME_MESSAGE_ENABLED", false); // Skip messages
            // Gotta go fast
            GameSettings.setBool("MINION_SPAWN_ALLOW_GRACE", false);
            GameSettings.setReal("MINION_SPAWN_LEVEL_TIME", 180.0); // 3 minutes
            
            GameSettings.setBool("FORCE_DEBUG_MODE", true);
            GameSettings.setBool("PICKMODE_REMOVE_AFK", false);
            GameSettings.setReal("GAME_INIT_START_DELAY", 0.1);
        }
    }
}

//! endzinc