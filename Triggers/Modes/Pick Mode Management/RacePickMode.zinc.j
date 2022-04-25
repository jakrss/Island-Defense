//! zinc

// Simply a module that gets implemented by Pick Modes containing the default setup

library RacePickMode requires RacePicker, GameSettings, optional PerksSystem {
    public module RacePickModeModule {
        public GameTimer graceDelayTimer = 0;
        
        public method setupCamera(PlayerData p){
            rect r = null;
            if (p.class() == PlayerData.CLASS_DEFENDER){
                r = Rect(-10752, 8704, -10752, 8704);
            }
            else if (p.class() == PlayerData.CLASS_TITAN){
                r = Rect(-9952, 10304, -9952, 10304);
            }
            else {
                return;
            }
            PlayerDataPick[p].restrictCamera(r);
            RemoveRect(r);
            r = null;
        }
        public method setupPicker(PlayerData q){
            PlayerDataPick p = PlayerDataPick[q];
            p.removePicker();
            p.createPicker();
        }
        
        public method setupPlayer(PlayerData p){
            this.setupCamera(p);
            this.setupPicker(p);
            
            // Safe to assume that they haven't picked yet?
            PlayerDataPick[p].setPicked(false);
            PlayerDataPick[p].clearRaceRandomBans();
            
            this.onPlayerSetup(p);
        }
        
        public method setupPlayers(){
            PlayerDataArray list = 0;
            integer i = 0;
            list = PlayerData.all();
            for (0 <= i < list.size()){
                this.setupPlayer(list.at(i));
            }
            list.destroy();
        }
        
        public method setupPickShops(){
            player p = Player(PLAYER_NEUTRAL_PASSIVE);
            // Clean up in case of something going wrong!
            UnitManager.despawnPickShops();
            // Spawn Pick shops
            UnitManager.spawnPickShops();
        }

        public method setupNormally(){
            this.setupPlayers();
            this.setupPickShops();
        }
        
        private method endNormallyCheck() {
            PlayerDataArray list = 0;
            PlayerDataPick p = 0;
            integer i = 0;
            
            // Check if Defender's haven't moved, and make them observers.
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            for (0 <= i < list.size()){
                p = PlayerDataPick[list[i]];
                if (!p.hasMoved() && GameSettings.getBool("PICKMODE_REMOVE_AFK")){
                    // They haven't moved or picked! Now let's make them an observer.
                    Game.say(p.nameColored() + "|cff99b4d1 has been changed to an observer for not moving in the allocated time.|r");
                    UnitManager.removePlayerUnits(p.playerData);
                    p.setClass(PlayerData.CLASS_OBSERVER);
                }
                else if (!p.hasPicked()){
                    Game.say(p.nameColored() + "|cff99b4d1 has been changed to an observer for not choosing in the allocated time.|r");
                    UnitManager.removePlayerUnits(p.playerData);
                    p.setClass(PlayerData.CLASS_OBSERVER);
                }
            }
            list.destroy();
            
            list = PlayerData.withClass(PlayerData.CLASS_OBSERVER);
            for (0 <= i < list.size()){
                p = PlayerDataPick[list[i]];
                p.freeCamera();
                if (GetLocalPlayer() == p.player()){
                    PanCameraToTimed(GetUnitX(UnitManager.TITAN_SPELL_WELL),
                                     GetUnitY(UnitManager.TITAN_SPELL_WELL), 0);
                }
            }
            list.destroy();
        }
        
        public method endNormally(){
            PlayerDataArray list = 0;
            PlayerDataPick p = 0;
            integer i = 0;
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            for (0 <= i < list.size()){
                p = PlayerDataPick[list[i]];
                p.removePicker();
            }
            list.destroy();
            list = 0;
            UnitManager.despawnPickShops();
            
            if (graceDelayTimer != 0) {
                graceDelayTimer.deleteNow();
            }
            
            this.endNormallyCheck();
            
            RacePicker.finish();
        }
        
        public method meetsVoteRequirementsNormal(RacePickModeVotes mode) -> boolean {
            // Check all titan's agreed
            if (mode.titanVotes == PlayerData.countClass(PlayerData.CLASS_TITAN) ||
                !GameSettings.getBool("PICKMODE_VOTE_REQUIRES_TITAN")){
                // Titans and majority of defenders voted, enough for me!
                // Or it's default but titan wanted something else? Suck it!
                return true;
            }
            
            Game.say("|cffbbbb20The Titan did not agree to the most voted game mode.|r");
            return false;
        }
        
        // The default pick method
        public method pickedNormal(PlayerDataPick p){
            PlayerDataArray list = 0;
            integer i = 0;
            integer titansPicked = 0;
            
            p.removePicker();
            
            if (p.class() == PlayerData.CLASS_DEFENDER){
                UnitManager.spawnDefender(p.playerData);
            }
            else if (p.class() == PlayerData.CLASS_TITAN){
                list = PlayerData.withClass(PlayerData.CLASS_TITAN);
                for (0 <= i < list.size()){
                    if (PlayerDataPick[list[i]].hasPicked()){
                        titansPicked = titansPicked + 1;
                    }
                }
                list.destroy();
                list = 0;
                
                // If all Titans have picked, create them!
                if (titansPicked >= PlayerData.countClass(PlayerData.CLASS_TITAN)){
                    UnitManager.spawnTitans();
                    // We're done picking! Time to clean up...
                    this.end();
                    return;
                }
                else {
                    Game.say("|cffff0000Waiting for all of the Titans to pick...|r");
                }
            }
        }
        
        public method onPickerItemEventNormal(PlayerDataPick p, unit seller, item it) -> Race {
            integer id = GetItemTypeId(it);
			Race r = 0;
            if (!p.hasPicked()) {
                if (p.class() == PlayerData.CLASS_DEFENDER){
                    r = DefenderRace.fromItemId(id);
                }
                else if (p.class() == PlayerData.CLASS_TITAN){
                    r = TitanRace.fromItemId(id);
                }

                p.pick(r);

                RemoveItem(it);
            }
			
			return r;
        }
        
        public method onUnitCreationNormal(PlayerDataPick p) {
            integer delta = GetRandomInt(1, 100);
            unit u = p.unit().unit();
            
            Game.onPlayerRaceChosen(p.playerData);
            
            // Setup tech
            DefenderUnit.prepare(p.playerData);
            
            if (GetUnitAbilityLevel(u, 'A013') > 0) {
                // Set inventory level to 2, to fix a random bug where it wouldn't update
                SetUnitAbilityLevel(u, 'A013', 1);
            }

            // Abilities
            p.race().onSpawn(u);
            
            // Race Specific
            if (p.class() == PlayerData.CLASS_DEFENDER) {
                // Random Effects
                if (p.isRandoming()) {
                    Game.sayClass(PlayerData.CLASS_DEFENDER, 
                                  p.nameColored() + "|cff99b4d1 has randomed " + p.race().toString() + ".|r");
                    p.setWood(p.wood() + 70);
						if     	 (delta <= 5) { UnitAddItem(u, CreateItem('I04V',0,0)); 		// 5%  // Large Health Bonus
						} else if (delta <= 15) { UnitAddItem(u, CreateItem('I08B',0,0)); 	// 10%  // Lucky Resources
						} else if (delta <= 30) { UnitAddItem(u, CreateItem('I088',0,0)); 	// 15%  // Small Health Bonus
						} else if (delta <= 50) { UnitAddItem(u, CreateItem('I087',0,0)); 	// 20%  // Temporary Speed
                    } else if (delta <= 55) {													// 5%  // Island's Blessing
                        UnitAddAbility(u, 'A0P2'); UnitMakeAbilityPermanent(u, true, 'A0P2');
                    }
                }
                else {
                    Game.sayClass(PlayerData.CLASS_DEFENDER, 
                                  p.nameColored() + "|cff99b4d1 has chosen " + p.race().toString() + ".|r");
                    p.setWood(p.wood() + 30);
                }
                // Set initial position
                p.setInitialPosition(GetUnitX(u), GetUnitY(u));
                
                MetaData.onSpawn("defender", u);
            }
            else {
                // Preload Minion (prevents lag later on?)
                RemoveUnit(CreateUnit(p.player(), p.race().childId(), 0, 0, 270));
                
                // Set resources
                p.setGold(GameSettings.getInt("TITAN_START_GOLD"));
                p.setWood(GameSettings.getInt("TITAN_START_WOOD"));
                
                // Defaults
                UnitAddItem(u, CreateItem('I00P',0,0));                                 		// 100% // Ankh of Reincarnation
                // Random Chances
                if (p.isRandoming()){
                    if (delta <= 10) {       	  	UnitAddItem(u, CreateItem('I00C',0,0)); 	// 10%  // Regenerative Spines
                    }    else if (delta <= 20) {  	UnitAddItem(u, CreateItem('I00E',0,0));		// 10%  // Webbed Feet
                    }    else if (delta <= 30) {  	UnitAddItem(u, CreateItem('I00D',0,0)); 	// 10%  // Surge Trident
                    }    else if (delta <= 40) {  	UnitAddItem(u, CreateItem('I00B',0,0)); 	// 10%   // Gem of Haste
                    }    else if (delta <= 50) {  	UnitAddItem(u, CreateItem('I05P',0,0)); 	// 10% // Shadow Shard
                    }    else if (delta <= 60) {  	UnitAddItem(u, CreateItem('I016',0,0)); 	// 10% // Pearl of Vision
                    }    else if (delta <= 70) {  	UnitAddItem(u, CreateItem('I042',0,0)); 	// 10% // Reef Shield
					}	else if (delta <= 80) {  	UnitAddItem(u, CreateItem('I05Q',0,0)); 	// 10% // Scepter of Apparition
					}	else if (delta <= 90) {  	UnitAddItem(u, CreateItem('I05Y',0,0)); 	// 10% // Voodoo Idol
					}	else if (delta > 90) { 	UnitAddItem(u, CreateItem('I05O',0,0));		// 10% // Scouter's Necklace
                    }
                    
                    p.setGold(p.gold() + GameSettings.getInt("TITAN_RANDOM_GOLD_BONUS"));
                    p.setWood(p.wood() + GameSettings.getInt("TITAN_RANDOM_WOOD_BONUS"));
                }
                
                MetaData.onSpawn("titan", u);
            }

            p.freeCamera();
            if (p.player() == GetLocalPlayer()) {
                PanCameraToTimed(GetUnitX(UnitManager.TITAN_SPELL_WELL),
                                 GetUnitY(UnitManager.TITAN_SPELL_WELL), 0);
                            
                ClearSelection();
                SelectUnit(u, true);
            }
            
            static if (LIBRARY_PerksSystem){
                PerksSystem.onSpawn(p.playerData);
            }
            
            u = null;
        }
		
		public method getStartDelayNormal() -> real {
			return GameSettings.getReal("PICKMODE_DEFAULT_START_DELAY");
		}
        
        private static method create() -> thistype {
            // Will this prevent anyone creating one of these objects without onInit?
            return thistype.allocate();
        }
    
        private static method onInit() {
            // Here we have to register the type with RacePicker so it knows
            // Hmm.. we have another problem. Because of how interfaces work, we 
            // can't use static structs
            RacePicker.register.execute(thistype.create());
        }
        
        private integer mIndex = 0;
        public method setIndex(integer i){
            this.mIndex = i;
        }
        
        public method index() -> integer {
            return this.mIndex;
        }
    }
    
    public interface RacePickMode {
        method name() -> string;
        method shortName() -> string;
        method description() -> string;
        
        method gameMode() -> string = "ID";
		method getStartDelay() -> real;
		method cycleRaces() -> boolean = true;
        
        method onPlayerSetup(PlayerData p) = null;
        method setup();
        method start();
        method picked(PlayerDataPick p);
        method onUnitCreation(PlayerDataPick p);
        method onPickerItemEvent(PlayerDataPick p, unit seller, item it);
        method end();
		
		method terminate() = null;
        
        method meetsVoteRequirements(RacePickModeVotes mode) -> boolean = true;
        
        method setupCamera(PlayerData p) = null;
        method setupPicker(PlayerData p) = null;
        method setupPlayer(PlayerData p) = null;
        method setupPlayers() = null;
        method setupPickShops() = null;
        
        method setIndex(integer i);
        method index() -> integer;
    }
}

//! endzinc