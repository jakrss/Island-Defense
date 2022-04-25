//! zinc

library AutoAttackTweak requires TweakManager {
    public struct AutoAttackTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Auto-Attack";
        }
        public method shortName() -> string {
            return "AA";
        }
        public method description() -> string {
            return "Changes whether or not your units use the auto-attack variant of spells.\n" +
                   "Currently only works with Demonicus' Shadow Walk.";
        }
        public method command() -> string {
            return "-aa,-autoattack";
        }
        public method hidden() -> boolean {
            return true;
        }
        
        // -aa [on/off]
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            string arg = "";
            
            if (p.class() != PlayerData.CLASS_TITAN) return;
			
            if (args.size() > 0){
                arg = StringCase(args[0].getStr(), false);
                if (arg == "on"){
                    GameSettings.setBool("TITAN_AUTOATTACK_ON", true);
                    p.say("|cff00bfffAuto-Attack has been turned |r|cffff0000on|r|cff00bfff. It will take effect next time you use your abilities.|r");
                }
                else {
                    GameSettings.setBool("TITAN_AUTOATTACK_ON", false);
                    p.say("|cff00bfffAuto-Attack has been turned |r|cffff0000off|r|cff00bfff. It will take effect next time you use your abilities.|r");
                }
            }
            else {
                p.say("|cff00bfffCommand usage: |r-aa|cff00bfff <|r|cffff0000on|r|cff00bfff/|r|cffff0000off|r|cff00bfff>|r");
            }
        }
    }
}
//! endzinc