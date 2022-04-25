//! zinc

library GoldStolenCommand requires TweakManager {
    public struct GoldStolenCommand extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Gold Stolen";
        }
        public method shortName() -> string {
            return "GS";
        }
        public method description() -> string {
            return "Displays the amount of Gold gathered by Defenders from the Gold Mound.";
        }
        public method command() -> string {
            return "-gs";
        }
        public method hidden() -> boolean {
            return true;
        }
        
        public method initialize() {
			GameSettings.setInt ("TITAN_MOUND_GOLD_STOLEN", 0);
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            integer i = GameSettings.getInt("TITAN_MOUND_GOLD_STOLEN");
			
			p.say("|cffff0000" + I2S(i) + "|r |cff00bfffGold has been stolen from the Titan's Gold Mound this game.|r");
        }
    }
}
//! endzinc