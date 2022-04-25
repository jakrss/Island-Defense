//! zinc

library RacePickModeUniquePick requires RacePickMode, UnitManager {
    private struct DefenderRaceUniquePick {
		DefenderRace race = 0;
		integer playerCount = 0;
		PlayerDataPick players[100];
		boolean randomed[100];
	
		public static method create(DefenderRace r) -> thistype {
			thistype this = thistype.allocate();
			this.race = r;
			this.playerCount = 0;
			return this;
		}
		
		method addPlayer(PlayerDataPick p, boolean random) {
			this.players[this.playerCount] = p;
			this.randomed[this.playerCount] = random;
			this.playerCount = this.playerCount + 1;
		}
		
		method resolve() -> PlayerDataPick {
			PlayerDataPick p = 0;
			boolean r = false;
			integer i = 0;
			integer indicies[];
			integer indiciesCount = 0;
			
			for (0 <= i < this.playerCount) {
				if (this.players[i].race() == NullRace.instance()) {
					// Add the player index to the pool (if they have not been resolved to a race yet)
					indicies[indiciesCount] = i;
					indiciesCount = indiciesCount + 1;
				}
			}
				
			if (indiciesCount > 0) {
				i = indicies[GetRandomInt(0, indiciesCount - 1)];
				p = this.players[i];
				r = this.randomed[i];
				p.setRandoming(r);
				p.setRace(this.race);
			}
			
			return p;
		}
    }
    
    public struct RacePickModeUniquePick extends RacePickMode {
        module RacePickModeModule;
        
        method name() -> string {
            return "Unique Pick";
        }
        method shortName() -> string {
            return "UP";
        }
        method description() -> string {
            return "All players will be able to choose a unique race.";
        }
		
		private boolean spawnStarted = false;
		private boolean normalPick = false;
		
		method cycleRaces() -> boolean {
			return false;
		}
        
        method setup(){
            this.setupNormally();
			this.spawnStarted = false;
			this.normalPick = false;
        }
		
        public method onPlayerSetup(PlayerData p){
			if (p.class() == PlayerData.CLASS_DEFENDER) {
				p.setGold(p.gold() + 1);
			}
        }
		
		private method resolveDefenders() {
			PlayerDataArray list = 0;
            PlayerDataPick p = 0;
            integer i = 0;
			integer j = 0;
			integer index = 0;
			DefenderRace r = 0;
			boolean randomed = false;
			boolean hasRandom = false;
			boolean preRandom = false;
			item it = null;
			DefenderRace selections[];
			boolean selectionRandomMask[];
			DefenderRaceUniquePick selectionPick[];
			DefenderRace selectionPickRaces[];
			integer selectionPickRacesCount = 0;
            
            // Now we want to let all the Defenders choose their race
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            for (0 <= i < list.size()){
                p = PlayerDataPick[list[i]];
                if (!p.isLeaving() && !p.hasLeft() && !p.hasPicked()){
					preRandom = p.isRandoming();
					hasRandom = preRandom || (p.isFake() && GameSettings.getBool("FAKE_PLAYERS_AUTOPICK"));
					p.setRace(NullRace.instance());
					p.setRandoming(false);
					for (0 <= j < 6) {
						it = UnitItemInSlot(p.picker(), j);
						index = (p.id() * 6) + j;
						if (it == null && preRandom) {
							it = UnitAddItemById(p.picker(), 'I006');
						}
						if (it != null) {
							// Get DefenderRace
							if (GetItemTypeId(it) == 'I006') {
								// Should use bans, we don't care about unique for now
								hasRandom = true;
								randomed = true;
								r = PlayerDataPick.getPlayerDataPickRandomRaceUniqueWithBans(p);
							}
							else {
								randomed = false;
								r = DefenderRace.fromItemId(GetItemTypeId(it));
							}
							selections[index] = r;
							selectionRandomMask[index] = randomed;
							RemoveItem(it);
							it = null;
						}
					}
					
					// If the player has chosen one random, we can always random on that.
					// This will be overridden if a actual race is chosen, see resolve()
					// preRandom is used for things such as lazy random. This will ensure that a 
					// race is randomed if no matches are found
					if (hasRandom) {
						p.setRandoming(true);
					}
                }
            }
			
			// Resolve (sets the correct races, does not pick)
			for (0 <= j < 6) {
				selectionPickRacesCount = 0;
				// Re-use our player list
				for (0 <= i < list.size()){
					p = PlayerDataPick[list[i]];
					
					if (!p.isLeaving() && !p.hasLeft() && !p.hasPicked()){
						index = (p.id() * 6) + j;
						r = selections[index];
						
						if (r != 0 && p.race() == NullRace.instance()) {
							if (selectionPick[r] == 0) {
								selectionPick[r] = DefenderRaceUniquePick.create(r);
								selectionPickRaces[selectionPickRacesCount] = r;
								selectionPickRacesCount = selectionPickRacesCount + 1;
							}
							
							if (selectionPick[r] > 0) {
								selectionPick[r].addPlayer(p, selectionRandomMask[index]);
							}
						}
					}
				}
				
				// Now resolve selections
				for (0 <= i < selectionPickRacesCount) {
					r = selectionPickRaces[i];
					if (selectionPick[r] > 0) {
						selectionPick[r].resolve();
						selectionPick[r].destroy();
						selectionPick[r] = -1; // Denotes resolved
					}
					selectionPickRaces[i] = 0;
				}
			}
            list.destroy();
            list = 0;
		}
        
        method start(){
			PlayerDataArray list = 0;
            PlayerDataPick p = 0;
            integer i = 0;
			
			this.spawnStarted = false;
			this.normalPick = false;
			
			this.resolveDefenders();
			
			this.spawnStarted = true;
			
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            for (0 <= i < list.size()){
                p = PlayerDataPick[list[i]];
                if (!p.isLeaving() && !p.hasLeft() && !p.hasPicked()){
					if (p.race() != NullRace.instance() || p.isRandoming()) {
						p.pick(p.race());
					}
					else {
						// For everyone that we couldn't spawn, give them a chance to pick properly
						p.say("|cff99b4d1Failed to assign you to your desired class, please pick from the remaining Defenders.|r");
						p.setCanPick(true);
					}
                }
            }
            list.destroy();
            list = 0;
			
			this.normalPick = true;
            
            // Next, we want to start the timer for the Titan to spawn
            graceDelayTimer = GameTimer.newNamed(function(GameTimer t){
                PlayerDataArray list = 0;
                integer i = 0;
                PlayerDataPick p = 0;
                
                list = PlayerData.withClass(PlayerData.CLASS_TITAN);
                for (0 <= i < list.size()){
                    p = PlayerDataPick[list[i]];
                    if (!p.isLeaving() && !p.hasLeft() && !p.hasPicked()){
                        if (p.isRandoming() || (p.isFake() && GameSettings.getBool("FAKE_PLAYERS_AUTOPICK"))){
                            p.pick(p.race());
                        }
                        else {
                            p.setCanPick(true);
                        }
                    }
                }
                list.destroy();
                list = 0;
            }, "TitanDelayTime");
            graceDelayTimer.showDialog("Grace Period");
            graceDelayTimer.start(GameSettings.getReal("TITAN_SPAWN_GRACE_TIME"));
        }
        
        method picked(PlayerDataPick p){
			if (!this.spawnStarted) {
				p.setRace(NullRace.instance());
				p.setPicked(false);
				return;
			}
			// Since p.race() will count in the following, we need to check if there are more than 1
			if (this.normalPick && PlayerData.countRace(p.race()) > 1) {
				p.setPicked(false);
				p.setGold(p.gold() + 1);
				p.setRace(NullRace.instance());
				p.say("|cff99b4d1Someone else has chosen this Defender, please choose another one.|r");
				return;
			}
			this.pickedNormal(p);
        }
        
        method onUnitCreation(PlayerDataPick p){
            this.onUnitCreationNormal(p);
        }
		method onPickerItemEvent(PlayerDataPick p, unit seller, item it){
			Race r = 0;
			integer id = GetItemTypeId(it);
			integer i = 0;

			if (p.class() == PlayerData.CLASS_DEFENDER){
				if (this.spawnStarted) {
					r = this.onPickerItemEventNormal(p, seller, it);
				}
				else {
					r = DefenderRace.fromItemId(id);
					RemoveItem(it);
					
					if (r == 0 || r == NullRace.instance()) {
						p.say("|cff99b4d1Your remaining choices will be: |r|cffff0000Random|r");
						id = 'I006'; // Random Item
						for (0 <= i < 6) {
							if (UnitItemInSlot(p.picker(), i) == null) {
								UnitAddItemToSlotById(p.picker(), id, i);
							}
						}
					}
					else {
						for (0 <= i < 6) {
							if (UnitItemInSlot(p.picker(), i) == null) break;
						}
						p.say("|cff99b4d1Your #" + I2S(i+1) + " choice is: |r|cffff0000" + r.toString() + "|r");
						id = r.itemId();
						UnitAddItemById(p.picker(), id);
						p.playerData.setGold(p.playerData.gold() + 1);
					}
				}
			}
			else if (p.class() == PlayerData.CLASS_TITAN){
				this.onPickerItemEventNormal(p, seller, it);
			}
        }
		method getStartDelay() -> real {
			return this.getStartDelayNormal() + 5.0; // Add 5 seconds
		}
        method end(){
            this.endNormally();
        }
    }
}

//! endzinc