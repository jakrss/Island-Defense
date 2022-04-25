//! zinc

library RacePickModeBuilderRandom requires RacePickMode {
    public struct RacePickModeBuilderRandom extends RacePickMode {
        module RacePickModeModule;
        
        method name() -> string {
            return "Builder Random";
        }
        method shortName() -> string {
            return "BR";
        }
        method description() -> string {
            return "All Defenders' races will be selected at random.";
        }
        
        // Override
        public method onPlayerSetup(PlayerData p){
            if (p.class() == PlayerData.CLASS_DEFENDER){
                PlayerDataPick[p].setRandoming(true);
            }
        }
        
        method setup(){
            this.setupNormally();
        }
        
         method meetsVoteRequirements(RacePickModeVotes mode) -> boolean {
            return this.meetsVoteRequirementsNormal(mode);
        }
        
        method start(){
            PlayerDataArray list = 0;
            PlayerDataPick p = 0;
            integer i = 0;

            // Now we want to spawn all the Defenders
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            for (0 <= i < list.size()){
                p = PlayerDataPick[list[i]];
                if (!p.isLeaving() && !p.hasLeft() && !p.hasPicked())
                    p.pick(p.race());
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
			return this.getStartDelayNormal();
		}
        method end(){
            this.endNormally();
        }
    }
}

//! endzinc