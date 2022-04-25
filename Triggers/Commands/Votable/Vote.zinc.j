//! zinc

library VoteTweak requires TweakManager, PlayerDataMultiboard {
    public struct VoteTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Vote";
        }
        public method shortName() -> string {
            return "VOTE";
        }
        public method description() -> string {
            return "Allows you to change whether or not the voting board is displayed.";
        }
        public method command() -> string {
            return "-vote,-v,-vm,-votemessages,-vb,-voteboard";
        }
        
        public method activate(Args args){
            PlayerData q = PlayerData.get(GetTriggerPlayer());
            PlayerDataMultiboard p = 0;
            
            string action = "";
            
            if (!PlayerDataMultiboard.initialized()){
                p.say("|cffff0000Please wait before using this command.|r");
                return;
            }
            
            p = PlayerDataMultiboard[q];
            if (args.size() == 0){
                if (GetEnteredCommand() == "-vb" || GetEnteredCommand() == "-voteboard") {
                    p.setVotingEnabled(!p.isVotingEnabled());
                }
                else if (GetEnteredCommand() == "-vm" || GetEnteredCommand() == "-votemessages") {
                    p.setVotingMessagesEnabled(!p.areVotingMessagesEnabled());
                }
                else {
                    p.say("|cff00bfffCommand usage: -vote board/messages [on/off]|r");
                }
                return;
            }
            action = args[0].getStr();
            if (StringCase(action, false) == "board" || StringCase(action, false) == "b"){
                if (args.size() > 1){
                    p.setVotingEnabled(StringCase(args[1].getStr(), false) == "on");
                }
                else {
                    p.setVotingEnabled(!p.isVotingEnabled());
                }
            }
            else if (StringCase(action, false) == "messages" || StringCase(action, false) == "m") {
                if (args.size() > 1) {
                    p.setVotingMessagesEnabled(StringCase(args[1].getStr(), false) == "on");
                }
                else {
                    p.setVotingMessagesEnabled(!p.areVotingMessagesEnabled());
                }
            }
            else if (GetEnteredCommand() == "-vb" || GetEnteredCommand() == "-voteboard") {
                p.setVotingEnabled(StringCase(action, false) == "on");
            }
            else if (GetEnteredCommand() == "-vm" || GetEnteredCommand() == "-votemessages") {
                p.setVotingMessagesEnabled(StringCase(action, false) == "on");
            }
            else if (VoteBoardGeneric.instance() != 0) {
                VoteBoardGeneric.instance().vote(q, action);
            }
        }
    }
}
//! endzinc