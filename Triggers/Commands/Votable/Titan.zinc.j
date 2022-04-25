//! zinc

library TitanTweak requires TweakManager {
    public struct TitanTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Titan";
        }
        public method shortName() -> string {
            return "TITAN";
        }
        public method description() -> string {
            return "This command is only usable when a new Titan player is needed. You will be switched to being the Titan.";
        }
        public method command() -> string {
            return "-titan";
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            if (TitanFinder.isActive() && TitanFinder.isMethod(TitanFinder.METHOD_COMMAND)){
                TitanFinder.foundNewTitan(p);
            }
            else {
                p.say("|cffff0000A new Titan is not required at the moment.|r");
            }
        }
    }
}
//! endzinc