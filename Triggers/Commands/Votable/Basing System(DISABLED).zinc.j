//! zinc

library BasingSystemTweak requires TweakManager {
    public struct BasingSystemTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Basing System";
        }
        public method shortName() -> string {
            return "BASING SYSTEM";
        }
        public method description() -> string {
            return "Disables the basing system for the builders.";
        }
        public method command() -> string {
            return "-bs, -basingsystem, -basing";
        }
        
        public method isGameTweak() -> boolean {
            return true;
        }
        
        public method hidden() -> boolean {
            return true;
        }
        
        public method activated() -> boolean {
            return (GameSettings.getBool("BASING_SYSTEM_ACTIVATED"));
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            if (p.class() == PlayerData.CLASS_TITAN){
                PlaySoundBJ(gg_snd_Titan_IMustFeed);
                GameSettings.setBool("BASING_SYSTEM_ACTIVATED", true);
            }
        }
        
        public method deactivate(){
            GameSettings.setBool("BASING_SYSTEM_ACTIVATED", true);
        }
    }
}
//! endzinc