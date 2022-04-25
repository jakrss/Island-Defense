//! zinc

library HelpTweak requires TweakManager {
    public struct HelpTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Help";
        }
        public method shortName() -> string {
            return "HELP";
        }
        public method description() -> string {
            return "Gives you information about available commands.";
        }
        public method command() -> string {
            return "-help";
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            string arg = "";
            Tweak tweak = 0;
            
            if (args.size() > 0){
                arg = StringCase(args[0].getStr(), true);
                tweak = TweakManager.tweakByShortName(arg);
                
                if (tweak != 0){
                    p.say("|cffff0000" + tweak.name() + "|r|cff00bfff: " + tweak.description() + "|r");
                }
                else {
                    p.say("|cffff0000Could not find that command. Please try again.|r");
                }
            }
            else {
                TweakManager.printTweaksForPlayer(p);
                p.say("|cff00bfffType -help <command> for more information.|r");
            }
        }
    }
}
//! endzinc