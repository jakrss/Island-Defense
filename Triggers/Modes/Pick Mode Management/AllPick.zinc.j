//! zinc

library RacePickModeAllPick requires RacePickMode {
    public struct RacePickModeAllPick extends RacePickMode {
        module RacePickModeModule;
        
        method name() -> string {
            return "All Pick";
        }
        method shortName() -> string {
            return "AP";
        }
        method description() -> string {
            return "All players will be able to choose their desired races.";
        }
        
        method setup() {
            this.setupNormally();
        }
	
	public method onPlayerSetup(PlayerData p){
			if (p.class() == PlayerData.CLASS_DEFENDER) {
				p.setGold(p.gold() + 1);
			}
        }
        
         method meetsVoteRequirements(RacePickModeVotes mode) -> boolean {
            return this.meetsVoteRequirementsNormal(mode);
        }
        
        method start(){
            PlayerDataArray list = 0;
            PlayerDataPick p = 0;
            integer i = 0;
            
            // Now we want to let all the Defenders choose their race
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            for (0 <= i < list.size()){
                p = PlayerDataPick[list[i]];
                if (!p.isLeaving() && !p.hasLeft() && !p.hasPicked()){
                    if (p.isRandoming()){
                        p.pick(p.race());
                    }
                    else if (p.isFake() && GameSettings.getBool("FAKE_PLAYERS_AUTOPICK")){
                        p.say("You're fake, so I'm picking for you!");
                        p.pick(p.race());
                    }
                    else {
                        p.setCanPick(true);
                    }
                }
            }
            list.destroy();
            list = 0;
            
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
            this.pickedNormal(p);
        }
	
        method onUnitCreation(PlayerDataPick p){
            this.onUnitCreationNormal(p);
        }
	
	method onPickerItemEvent(PlayerDataPick p, unit seller, item it){
            this.onPickerItemEventNormal(p, seller, it);
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