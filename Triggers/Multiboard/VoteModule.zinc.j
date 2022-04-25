//! zinc

library VoteModule requires Players {
    public struct VoteResult {
        public static integer VOTE_NONE = 1;
        public static integer VOTE_YES = 2;
        public static integer VOTE_NO = 3;
        private integer mVoted = 0;
        private string mVotes[12];
        private PlayerData mLastVoter = 0;
        private boolean mExpired = false;
        
        public method setExpired(){
            this.mExpired = true;
        }
        
        public method expired() -> boolean {
            return this.mExpired;
        }
        
        public method lastVoter() -> PlayerData {
            return this.mLastVoter;
        }
        
        public method operator[](PlayerData p) -> string {
            return this.mVotes[p.id()];
        }
        
        public method operator[]=(PlayerData p, string vote){
            this.mVotes[p.id()] = vote;
            this.mLastVoter = p;
        }
        
        public method isYes(PlayerData p) -> boolean {
            return StringCase(this.mVotes[p.id()], false) == "yes";
        }
        
        public method isNo(PlayerData p) -> boolean {
            return StringCase(this.mVotes[p.id()], false) == "no";
        }
        
        public method isNone(PlayerData p) -> boolean {
            return !this.isYes(p) && !this.isNo(p);
        }
        
        public method isEmpty(PlayerData p) -> boolean {
            return this.mVotes[p.id()] == "";
        }
        
        public method yesAll() -> integer {
            return this.yes(PlayerData.CLASS_NONE);
        }
        public method yes(integer class) -> integer {
            integer i = 0;
            integer count = 0;
            PlayerData p = 0;
            for (0 <= i < 12){
                if (PlayerData.has(Player(i))){
                    p = PlayerData.get(Player(i));
                    if ((p.class() == class || class == PlayerData.CLASS_NONE) 
                        && this.isYes(p))
                        count = count + 1;
                }
            }
            return count;
        }
        
        public method noAll() -> integer {
            return this.no(PlayerData.CLASS_NONE);
        }
        public method no(integer class) -> integer {
            integer i = 0;
            integer count = 0;
            PlayerData p = 0;
            for (0 <= i < 12){
                if (PlayerData.has(Player(i))){
                    p = PlayerData.get(Player(i));
                    if ((p.class() == class || class == PlayerData.CLASS_NONE) 
                        && this.isNo(p))
                        count = count + 1;
                }
            }
            return count;
        }
        
        public method noneAll() -> integer {
            return this.none(PlayerData.CLASS_NONE);
        }
        public method none(integer class) -> integer {
            integer i = 0;
            integer count = 0;
            PlayerData p = 0;
            for (0 <= i < 12){
                if (PlayerData.has(Player(i))){
                    p = PlayerData.get(Player(i));
                    if ((p.class() == class || class == PlayerData.CLASS_NONE) 
                        && this.isNone(p))
                        count = count + 1;
                }
            }
            return count;
        }
        
        public static method create() -> thistype {
            thistype this = thistype.allocate();
            integer i = 0;
            for (0 <= i < 12){
                if (PlayerData.has(Player(i))){
                    this.mVotes[i] = "";
                }
            }
            this.mExpired = false;
            return this;
        }
    }
    
    public type voteFunc extends function(VoteResult, VoteBoard);
    public type checkFunc extends function(PlayerData) -> boolean;
    
    public interface VoteBoard {
        public method name() -> string = "";
        public method forPlayer(PlayerData p) -> boolean = false;
        
        public method initialize();
        public method begin(string vote, checkFunc f, voteFunc v, real timeout, integer data) -> boolean; // Callback once complete
        public method update();
        public method terminate();
    }
    
    public module VoteModule {
        public VoteBoard currentVoteBoard = 0;
        public boolean mVoting = false;
        public boolean mVotingEnabled = true;
        public boolean mVotingMessagesEnabled = false;
        
        public method setVotingEnabled(boolean b){
            if (!b) this.mVoting = false;
            this.mVotingEnabled = b;
            
            if (!b)
                this.say("|cff00bfffThe voting board will no longer be displayed.|r");
            else
                this.say("|cff00bfffThe voting board will now be displayed.|r");
        }
        
        public method setVotingMessagesEnabled(boolean b) {
            this.mVotingMessagesEnabled = b;
            
            if (!b)
                this.say("|cff00bfffOnly key voting messages will now be displayed.|r");
            else
                this.say("|cff00bfffAll voting messages will now be displayed.|r");
        }
        
        public method isVotingEnabled() -> boolean {
            return this.mVotingEnabled;
        }
        
        public method isVoting() -> boolean {
            return this.mVoting;
        }
        
        public method areVotingMessagesEnabled() -> boolean {
            return this.mVotingMessagesEnabled;
        }
        
        public method setVoting(boolean b){
            if (!this.mVotingEnabled) return;
            this.mVoting = b;
        }
        
        public method startVoting(VoteBoard b){
            if (!b.forPlayer(this) || !this.isVotingEnabled()) return;
            this.mVoting = true;
            this.currentVoteBoard = b;
        }
    }
}

//! endzinc
