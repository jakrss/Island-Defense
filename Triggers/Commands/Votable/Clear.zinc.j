//! zinc

library ClearTweak requires TweakManager {
    public struct ClearTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Clear";
        }
        public method shortName() -> string {
            return "CLEAR";
        }
        public method description() -> string {
            return "Clears your screen.";
        }
        public method command() -> string {
            return "-clear,-cls";
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            if (GetLocalPlayer() == p.player()){
                ClearTextMessages();
            }
        }
    }
}
//! endzinc