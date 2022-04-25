//! zinc

library LightningOffCommand requires TweakManager, GameSettings {
    public struct LightningOffCommand extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Lightning Off";
        }
		
        public method shortName() -> string {
            return "LOFF";
        }
		
        public method description() -> string {
            return "Disables lightning effects for the Titan's abilities. Only usable by the Titan.";
        }
		
        public method command() -> string {
            return "-lightningoff,-lo,-loff,-nl,-nolightning,-nol";
        }
		public method hidden() -> boolean {
			return true;
		}
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            if (p == 0 || p.class() != PlayerData.CLASS_TITAN) return;
			
			Game.say("|cff00bfffThe Titan has disabled lightning effects (which may reduce the chance of desync). Please be aware that some effects will not look the same.|r");
			GameSettings.setBool("LIGHTNING_EFFECTS_ENABLED", false);
        }
    }
}
//! endzinc