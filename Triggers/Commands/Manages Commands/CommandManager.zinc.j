//! zinc

library TweakManager requires GameSettings, Players, CommandParser, StringLib {
    public struct TweakManager {
        private static Tweak tweaks[];
        private static integer index = 0;
        private static PlayerData lastPlayer = 0;
        private static boolean running = false;
        
        public static method register(Tweak tweak){
            string command = "";
            integer i = 0;
            StringSegments segments = 0;
            thistype.tweaks[thistype.index] = tweak;
            thistype.index = thistype.index + 1;
            
            segments = StringSegments.create(tweak.command(), ",");
            while (segments.hasMoreSegments()) {
                command = segments.nextSegment();
                // Register the Command
                Command[command].register(function(Args a){
                    Tweak tweak = 0;
                    PlayerData p = 0;
                    
                    if (!thistype.running) return;
                    tweak = thistype.tweakByCommand(a.command());
                    p = PlayerData.get(GetTriggerPlayer());
                    
                    if (p != 0 &&
                        tweak.canActivate(p) &&
                        !tweak.activated()){
                        TweakManager.activateWithPlayer(tweak, p, a);
                    }
                });
            }
            segments.destroy();
        }
        
        public static method getGameTweakLights() -> string {
            Tweak tweak = 0;
            integer i = 0;
            string lights = "";
            for (0 <= i < thistype.index){
                tweak = thistype.tweaks[i];
                if (tweak.isGameTweak()){
                    if (tweak.activated()){
                        lights = lights + "|cffffa500";
                    }
                    else {
                        lights = lights + "|cff2f4f4f";
                    }
                    lights = lights + tweak.shortName() + "|r ";
                }
            }
            return StringTrim(lights);
        }
        
        public static method tweakByCommand(string s) -> Tweak {
            Tweak tweak = 0;
            StringSegments segments = 0;
            integer i = 0;
            string command = "";
            for (0 <= i < thistype.index){
                tweak = thistype.tweaks[i];
                segments = StringSegments.create(tweak.command(), ",");
                while (segments.hasMoreSegments()) {
                    command = segments.nextSegment();
                    if (StringCase(command, false) == StringCase(s, false)){
                        return tweak;
                    }
                }
                segments.destroy();
            }
            
            return 0;
        }
        
        public static method tweakByShortName(string s) -> Tweak {
            Tweak tweak = 0;
            integer i = 0;
            for (0 <= i < thistype.index){
                tweak = thistype.tweaks[i];
                if (tweak.shortName() == s){
                    return tweak;
                }
            }
            return 0;
        }
        
        public static method activatedBy() -> PlayerData {
            return thistype.lastPlayer;
        }
        
        public static method activateWithPlayer(Tweak t, PlayerData p, Args args){
            thistype.lastPlayer = p;
            thistype.activate(t, args);
            thistype.lastPlayer = 0;
        }
        
        public static method activate(Tweak t, Args args){
            t.activate(args);
        }

        private static method getAvailableTweaksMessage() -> string {
            string message = "";
            integer i = 0;
            Tweak tweak = 0;
            message = "|cff00bfffAvailable Commands: |r\n";
            for (0 <= i < index){
                tweak = thistype.tweaks[i];
                if (!tweak.hidden()){
                    message = message + "|cff00bfff" + tweak.name() +
                              " (|r|cffff0000" + StringCase(tweak.shortName(), false) + "|r|cff00bfff)|r\n";
                }
            }
            return message;
        }
        
        public static method printTweaks(){
            Game.say(thistype.getAvailableTweaksMessage());
        }
        
        public static method printTweaksForPlayer(PlayerData p){
            p.say(thistype.getAvailableTweaksMessage());   
        }

        public static method initialize() -> boolean {
            integer i = 0;
            Tweak t = 0;
            for (0 <= i < thistype.index){
                t = thistype.tweaks[i];
                t.initialize();
            }
            thistype.running = true;
            return true;
        }
        
        public static method terminate(){
            integer i = 0;
            Tweak t = 0;
            thistype.running = false;
            
            // Go through and call deactivate on all tweaks
            for (0 <= i < thistype.index){
                t = thistype.tweaks[i];
                if (t.activated())
                    t.deactivate();
                t.terminate();
            }
        }
    }
    
    public module TweakModule {
        public method defaultMessageVoteSuccess(){
            PlayerData q = 0;
            PlayerDataMultiboard qm = 0;
            PlayerDataArray list = PlayerData.all();
            integer i = 0;
            
            Game.say("|cff00bfffVote complete! Activating the |r|cffff0000" + 
                        this.shortName() +
                        "|r|cff00bfff (|cffff0000" +
                        this.name() +
                        "|r|cff00bfff) tweak.|r");
            
            for (0 <= i < list.size()) {
                q = list[i];
                qm = PlayerDataMultiboard[q];
                
                if (qm == 0 || qm.areVotingMessagesEnabled()) {
                    q.say("|cff00bfffThis tweak: " + this.description() + "|r");
                }
            }
            list.destroy();
        }
        
        public method defaultMessageVoteYes(PlayerData p){
            PlayerData q = 0;
            PlayerDataMultiboard qm = 0;
            PlayerDataArray list = PlayerData.all();
            integer i = 0;
            for (0 <= i < list.size()) {
                q = list[i];
                qm = PlayerDataMultiboard[q];
                
                if (qm == 0 || qm.areVotingMessagesEnabled()) {
                    q.say(p.nameColored() + "|cff00bfff has voted [|r|cffff0000YES|r|cff00bfff] to activating the |r|cffff0000" + 
                        this.shortName() +
                        "|r|cff00bfff (|cffff0000" +
                        this.name() +
                        "|r|cff00bfff) tweak!");
                }
            }
            list.destroy();
        }
        public method defaultMessageVoteNo(PlayerData p){
            PlayerData q = 0;
            PlayerDataMultiboard qm = 0;
            PlayerDataArray list = PlayerData.all();
            integer i = 0;
            for (0 <= i < list.size()) {
                q = list[i];
                qm = PlayerDataMultiboard[q];
                
                if (qm == 0 || qm.areVotingMessagesEnabled()) {
                    q.say(p.nameColored() + "|cff00bfff has voted [|r|cffff0000NO|r|cff00bfff].");
                }
            }
            list.destroy();
        }
        
        public method defaultMessageVoteBusy(PlayerData p){
            p.say("|cff00bfffPlease wait until the current vote has finished.|r");
        }
        
        public method defaultMessageVoteBegin(PlayerData p){
            PlayerData q = 0;
            PlayerDataMultiboard qm = 0;
            PlayerDataArray list = PlayerData.all();
            integer i = 0;
            for (0 <= i < list.size()) {
                q = list[i];
                qm = PlayerDataMultiboard[q];
                
                if (qm == 0 || qm.areVotingMessagesEnabled()) {
                    q.say(p.nameColored() + "|cff00bfff has initiated the vote for |r|cffff0000" + 
                        this.shortName() +
                        "|r|cff00bfff (|cffff0000" +
                        this.name() +
                        "|r|cff00bfff) tweak.\nType \"-vote yes\" or \"-vote no\" to vote. You have |r|cffffff0030|r|cff00bfff seconds.\n" +
                        "This tweak: " + this.description() + "|r");
                }
                else {
                    q.say(p.nameColored() + "|cff00bfff has initiated the vote for |r|cffff0000" + 
                        this.shortName() + "|r|cff00bfff tweak.|r");
                }
            }
            list.destroy();
        }
        
        public method defaultMessageVoteFailed(){
            Game.say("|cff00bfffThe vote to enable the |r|cffff0000" + this.shortName() + "|r|cff00bfff tweak has failed! Please try again later.");
        }
        
        public method defaultMessageVoteNeedMore(integer current, integer required){
            Game.say("|cffffff00" + I2S(required - current) + "|r|cff00bfff more votes are required.|r");
        }
        
        private static method create() -> thistype {
            return thistype.allocate();
        }
        
        private static method onInit(){
            TweakManager.register.evaluate(thistype.create());
        }
    }
    
    public interface Tweak {
        public method name() -> string;
        public method shortName() -> string;
        public method description() -> string;
        public method command() -> string;
        
        public method hidden() -> boolean = false;
        
        public method isGameTweak() -> boolean = false;
        
        public method activated() -> boolean = false;
        
        public method canActivate(PlayerData p) -> boolean = true;
        
        public method initialize() = null;
        public method terminate() = null;
        public method activate(Args args) = null;
        public method deactivate() = null;
    }
}

//! endzinc