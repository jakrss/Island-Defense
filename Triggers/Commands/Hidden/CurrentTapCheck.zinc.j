//! zinc

library CurrentTapTweak requires TweakManager {
    public struct CurrentTapTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Current Tap";
        }
        public method shortName() -> string {
            return "CT";
        }
        public method description() -> string {
            return "Enable to show a ping on the minimap whenever Glacious' Current Tap ability activates.";
        }
        public method command() -> string {
            return "-ct,-currenttap";
        }
        public method hidden() -> boolean {
            return true;
        }
        
        public method initialize() {
            GameSettings.setBool("TITAN_GLACIOUS_SHOW_CURRENT_TAP_PINGS", false);
        }
        
        // -aa [on/off]
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            string arg = "";
            
            if (p.class() != PlayerData.CLASS_TITAN) return;
			
            if (args.size() > 0){
                arg = StringCase(args[0].getStr(), false);
                if (arg == "on"){
                    GameSettings.setBool("TITAN_GLACIOUS_SHOW_CURRENT_TAP_PINGS", true);
                    p.say("|cff00bfffCurrent Tap ping has been turned |r|cffff0000on|r|cff00bfff.|r");
                }
                else {
                    GameSettings.setBool("TITAN_GLACIOUS_SHOW_CURRENT_TAP_PINGS", false);
                    p.say("|cff00bfffCurrent Tap ping has been turned |r|cffff0000off|r|cff00bfff.|r");
                }
            }
            else {
                p.say("|cff00bfffCommand usage: |r-ct|cff00bfff <|r|cffff0000on|r|cff00bfff/|r|cffff0000off|r|cff00bfff>|r");
            }
        }
    }
}
//! endzinc