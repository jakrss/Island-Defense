//! zinc

library IslandDefenseTagGameMode requires IslandDefenseSystem, TagDefenderDeath {
    public struct IslandDefenseTagGameMode extends GameMode  {
		module TagDefenderDeath;
		
        public static method onInit() {
            thistype this = thistype.allocate();
            Game.register(this);
        }
		
        public method name() -> string {
            return "Island Defense Tag";
        }
        public method shortName() -> string {
            return "IDT";
        }
        public method description() -> string {
            return "Island Defense with a twist!";
        }
        
        public method isAvailable() -> boolean {
            // Count players, check that minimum are here.
            // 1v1?
            return true;
        }
        
        private integer winnerClass = PlayerData.CLASS_NONE;
        
        public method winningClass() -> integer {
            return winnerClass;
        }
		
		public static IslandDefenseGameMode IDGame = 0;
        
        public method setup() -> boolean {
			thistype.IDGame = Game["ID"];
            return thistype.IDGame.setup();
        }
        public method start() -> boolean {
            ExperienceSystem.initialize();
            PenaltyTimer.initialize();
            MercyLumber.initialize();
            MinionLumber.initialize();
            PeriodicTips.initialize();
            
            SuspendTimeOfDay(false);
			
            return true;
        }
        
        public method pause(){
            thistype.IDGame.pause();
        }
        
        public method resume(){
            thistype.IDGame.resume();
        }
        
        public method stop(){
            thistype.IDGame.stop();
        }
        
        public method restart(){
            thistype.IDGame.restart();
        }
        
        public method finish(){
            thistype.IDGame.finish();
        }
        
        public method checkVictory() -> boolean {
            return thistype.IDGame.checkVictory();
        }
        
        public method playerResult(PlayerData p) -> integer {
            return -1;
        }
        
        public method endGame(){
			thistype.IDGame.endGame();
        }
        
        public method checkTitanStatus() -> boolean {
			return thistype.IDGame.checkTitanStatus();
        }
        
        public method loadFakePlayers() {
			thistype.IDGame.loadFakePlayers();
        }
        
        public method setupPlayers() -> boolean {
			return thistype.IDGame.setupPlayers();
        }
    }
}

//! endzinc