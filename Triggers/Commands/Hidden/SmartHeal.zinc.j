//! zinc

library SmartHealCommand requires TweakManager {
    public struct SmartHealCommand extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Smart Heal";
        }
        public method shortName() -> string {
            return "SH";
        }
        public method description() -> string {
            return "Enable to force healing spells to heal the target with the lowest percentage of their maximum health.";
        }
        public method command() -> string {
            return "-sh";
        }
        public method hidden() -> boolean {
            return true;
        }
        
        public method initialize() {
            GameSettings.setBool("TITAN_HEALING_SMART_HEAL", true);
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            string arg = "";
			
            if (p.class() != PlayerData.CLASS_TITAN) return;
            
            if (args.size() > 0){
                arg = StringCase(args[0].getStr(), false);
                if (arg == "on"){
                    GameSettings.setBool("TITAN_HEALING_SMART_HEAL", true);
                    p.say("|cff00bfffSmart Healing has been turned |r|cffff0000on|r|cff00bfff.|r");
                }
                else {
                    GameSettings.setBool("TITAN_HEALING_SMART_HEAL", false);
                    p.say("|cff00bfffSmart Healing has been turned |r|cffff0000off|r|cff00bfff.|r");
                }
            }
            else {
                p.say("|cff00bfffCommand usage: |r-sh|cff00bfff <|r|cffff0000on|r|cff00bfff/|r|cffff0000off|r|cff00bfff>|r");
            }
        }
    }
}
//! endzinc