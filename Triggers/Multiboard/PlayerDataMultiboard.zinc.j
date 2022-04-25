//! zinc

library PlayerDataMultiboard requires Players, VoteModule {
    public interface ClassBoard {
        public method name() -> string = "";
        public method forClass(integer c) -> boolean = false;
        
        public method initialize();
        public method subscribe(PlayerData p);
        public method isSubscribed(PlayerData p) -> boolean;
        public method unsubscribe(PlayerData p);
        public method update();
        public method terminate();
    }
    
    public struct PlayerDataMultiboard extends PlayerDataExtension {
        module PlayerDataWrappings;
        module VoteModule;
        
        private ClassBoard currentBoard = 0;
        
        public method current() -> ClassBoard {
            return this.currentBoard;
        }
        
        public method setClassBoard(){
            if (this.currentBoard != 0)
                this.currentBoard.unsubscribe(this.playerData);
            this.currentBoard = MultiboardManager.classBoard(this.class());
            if (this.currentBoard != 0)
                this.currentBoard.subscribe(this.playerData);
        }
        
        public method update(){
            if (this.mVoting && this.mVotingEnabled){
                if (this.currentBoard == 0) return;
                if (this.currentBoard.isSubscribed(this.playerData)){
                    this.currentBoard.unsubscribe(this.playerData);
                }
            }
            else {
                this.currentVoteBoard = 0;
                if (this.currentBoard == 0 || !this.currentBoard.forClass(this.playerData.class())){
                    // Try to set the class board!
                    this.setClassBoard();
                    // If we failed, then we'll quit out now
                    if (this.currentBoard == 0) return;
                }
                if (!this.currentBoard.isSubscribed(this.playerData)){
                    this.currentBoard.subscribe(this.playerData);
                }
            }
        }
        
        public static method updateAll(){
            PlayerDataArray list = 0;
            integer i = 0;
            list = PlayerData.all();
            for (0 <= i < list.size()){
                PlayerDataMultiboard[list[i]].update();
            }
            list.destroy();
        }
        
        public method onSetup(){
            //Game.say("_");
            this.setClassBoard();
            //Game.say(this.nameColored() + " has been set up with " + this.currentBoard.name() + " as " + this.classString()); 
        }
        
        public method onTerminate(){
            if (this.currentBoard != 0)
                this.currentBoard.unsubscribe(this.playerData);
            this.currentBoard = 0;
        }
    }
}

//! endzinc
