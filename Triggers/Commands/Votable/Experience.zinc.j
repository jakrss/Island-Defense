//! zinc

library ExperienceTweak requires TweakManager {
    public struct ExperienceTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Double Experience";
        }
        public method shortName() -> string {
            return "EXP";
        }
        public method description() -> string {
            return "Doubles the experience that the Titan and his minions gain.";
        }
        public method command() -> string {
            return "-exp,-dxp,-xp";
        }
        
        public method isGameTweak() -> boolean {
            return true;
        }
        
        public method hidden() -> boolean {
            return true;
        }
        
        public method activated() -> boolean {
            return (GameSettings.getBool("TITAN_EXP_GLOBAL_FACTOR_DOUBLED"));
        }
        
        private method voteSuccess(){
            PlayerDataArray list = 0;
            PlayerData p = 0;
            integer i = 0;
            this.defaultMessageVoteSuccess();
            
            list = PlayerData.all();
            for (0 <= i < list.size()){
                p = list.at(i);
                if (GetLocalPlayer() == p.player()){
                    if (p.class() == PlayerData.CLASS_TITAN ||
                        p.class() == PlayerData.CLASS_MINION){
                        PlaySoundBJ(gg_snd_Titan_IMustFeed);
                    }
                    else {
                        PlaySoundBJ(gg_snd_Builder_ThisIsTooEasy);
                    }
                }
            }
            list.destroy();
            
            GameSettings.setBool("TITAN_EXP_GLOBAL_FACTOR_DOUBLED", true);
        }
        
        private method voteFailed(){
            this.defaultMessageVoteFailed();
        }
        
        private method required() -> integer {
            integer i = 0;
            integer count = 0;
            PlayerData p = 0;
            PlayerDataArray list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            for (0 <= i < list.size()){
                p = list.at(i);
                if (!p.isFake()) count = count + 1;
            }
            list.destroy();
            
            
            return R2I(I2R(count) + 1.0) / 2; // this ensures that it will round up, so 3 players = 2 required
        }
        
        private method vote(PlayerData p, VoteResult r){
            integer required = this.required();
            
            // If the vote expired, check conditions
            if (r.expired()){
                if (r.yes(PlayerData.CLASS_DEFENDER) >= required){
                    this.voteSuccess();
                }
                else {
                    this.voteFailed();
                }
                VoteBoardGeneric.instance().done();
            }
            else {
                // Ignore votes from Minion / Titan / Observers
                if (p.class() == PlayerData.CLASS_TITAN ||
                    p.class() == PlayerData.CLASS_MINION ||
                    p.class() == PlayerData.CLASS_OBSERVER) return;
                if (r.isYes(p)){
                    this.defaultMessageVoteYes(p);
                    if (r.yes(PlayerData.CLASS_DEFENDER) >= required){
                        this.voteSuccess();
                        VoteBoardGeneric.instance().done();
                    }
                    else {
                        // Display message of how many more votes are needed
                        this.defaultMessageVoteNeedMore(r.yes(PlayerData.CLASS_DEFENDER), required);
                    }
                }
                else if (r.isNo(p)){
                    this.defaultMessageVoteNo(p);
                }
            }
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            boolean vote = false;
            
            if (!Game.isState(Game.STATE_STARTED)) {
                this.defaultMessageVoteBusy(p);
                return;
            }

            if (PlayerData.countClass(PlayerData.CLASS_DEFENDER) <= 1){
                if (p.class() == PlayerData.CLASS_DEFENDER){
                    this.voteSuccess();
                    return;
                }
            }
            
            vote = VoteBoardGeneric.instance().begin(this.name(),
                function(PlayerData p) -> boolean {
                    return true;
                }, function(VoteResult r, integer data){
                    thistype this = data;
                    PlayerData p = r.lastVoter();
                    if (this.activated()) return;
                    this.vote(p, r);
            }, 30.0, this);
            if (!vote){
                if (VoteBoardGeneric.instance().voteData() == this){
                    VoteBoardGeneric.instance().vote(p, "yes");
                }
                else {
                    this.defaultMessageVoteBusy(p);
                }
            }
            else {
                PlaySoundBJ(gg_snd_Ready);
                this.defaultMessageVoteBegin(p);
                if (PlayerDataMultiboard[p].areVotingMessagesEnabled()) {
                    Game.say("|cffff0000IMPORTANT!|r|cffffff00 - Only Defender's votes will count towards activating this tweak.|r");
                }
                VoteBoardGeneric.instance().vote(p, "yes");
            }
        }
        public method deactivate(){
            GameSettings.setBool("TITAN_EXP_GLOBAL_FACTOR_DOUBLED", false);
        }
    }
}
//! endzinc