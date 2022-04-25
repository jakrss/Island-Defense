//! zinc

// Removes an Observer from the game.
// Voted on by Defenders.
// Requires 50% of Defenders to pass.

library BootTweak requires TweakManager, Dialog {
    private struct PlayerDataBoot {
        module PlayerDataWrappings;
        
        // Players that want this guy gone!
        private PlayerDataArray mVotesAgainst = 0;
        
        private method onSetup(){
            this.mVotesAgainst = PlayerDataArray.create();
        }
        
        private method onTerminate(){
            this.mVotesAgainst.destroy();
        }
        
        public method clear(){
            this.mVotesAgainst.clear();
        }
        
        public method hasBeenVotedAgainstBy(PlayerData p) -> boolean {
            return this.mVotesAgainst.has(p);
        }
        
        // Only want to count players that are still here!
        public method votesAgainst() -> integer {
            PlayerData p = 0;
            integer i = 0;
            integer count = 0;
            for (0 <= i < this.mVotesAgainst.size()){
                p = this.mVotesAgainst[i];
                if (p.class() == PlayerData.CLASS_DEFENDER){
                    if (!p.isLeaving() && !p.hasLeft()){
                        count = count + 1;
                    }
                }
            }
            return count;
        }
        
        // Player p wants to remove this player
        public method vote(PlayerData p) -> integer{
            if (!this.hasBeenVotedAgainstBy(p))
                this.mVotesAgainst.append(p);
            return this.votesAgainst();
        }
    }
    
    public struct BootTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Boot";
        }
        public method shortName() -> string {
            return "BOOT";
        }
        public method description() -> string {
            return "Removes an unwanted Observer from the game.";
        }
        public method command() -> string {
            return "-boot";
        }
        
        public method initialize(){
            PlayerDataBoot.initialize();
        }
        
        public method terminate(){
            PlayerDataBoot.terminate();
        }
        
        private method boot(PlayerData q){
            Dialog d = Dialog.create();
            d.SetMessage("You have been booted from the game!");
            d.AddButton("Quit",  HK_ESC);
            d.AddAction(function(){
                Dialog d = Dialog.Get();
                d.destroy();
                d = 0;
            });
            RemovePlayer(q.player(), PLAYER_GAME_RESULT_DEFEAT);
            d.Show(q.player());
            d = 0;
        }
        
        private method required() -> integer {
            integer i = 0;
            PlayerDataArray list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            PlayerData p = 0;
            integer count = 0;
            
            for (0 <= i < list.size()){
                p = list.at(i);
                if (!p.isFake()) count = count + 1;
            }
            list.destroy();
            
            return R2I(I2R(count) + 1.0) / 2; // this ensures that it will round up, so 3 players = 2 required
        }
        
        private method checkVotesAgainst(PlayerData q) -> boolean {
            integer votes = 0;
            integer required = 0;
            if (q.hasLeft() || q.isLeaving()) return false;
            
            votes = PlayerDataBoot[q].votesAgainst();
            required = this.required();
            
            if (votes >= required){
                // More than 50% of Defenders have voted
                Game.say("|cff00bfffVote has succeeded, |r" + q.nameColored() + "|cff00bfff will now be removed from the game.|r");
                this.boot(q);
                return true;
            }

            // Not enough have voted
            Game.say(I2S(required - votes) + "|cff00bfff more votes are required to remove |r" + q.nameColored() + "|cff00bfff from the game.|r");
            return false;
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            PlayerData q = 0;

            if (p.class() != PlayerData.CLASS_DEFENDER){
                p.say("|cffff0000Sorry, only Defenders are allowed to remove Observers from the game.|r");
                return;
            }
            if (args.size() == 0 || !args[0].isPlayer()){
                p.say("|cffff0000Please specify a player you would like to boot.|r");
                return;
            }
            q = PlayerData.get(args[0].getPlayer());
            if (q == 0 || q.isLeaving() || q.hasLeft()){
                p.say("|cffff0000You have specified an invalid player.|r");
                return;
            }
            if (q.class() != PlayerData.CLASS_OBSERVER){
                p.say("|cffff0000You must specify an Observer.|r");
                PlayerDataBoot[q].clear();
                return;
            }
            
            
            if (PlayerDataBoot[q].hasBeenVotedAgainstBy(p)){
                // Check if votes are enough
                if (this.checkVotesAgainst(q)) return;
                // They aren't, display error message.
                p.say("|cff00bfffYou have already voted to remove " + q.nameColored() + " from the game.|r");
                return;
            }
            
            // Valid boot command, now let's check the stats!
            PlayerDataBoot[q].vote(p);
            this.checkVotesAgainst(q);
        }
    }
}
//! endzinc