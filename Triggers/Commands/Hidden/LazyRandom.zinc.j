//! zinc

library LazyRandomTweak requires TweakManager {
    public struct LazyRandomTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Lazy Man's Random";
        }
        public method shortName() -> string {
            return "LAZY";
        }
        public method description() -> string {
            return "Random's your race for you!";
        }
        public method command() -> string {
            return "-";
        }
        public method hidden() -> boolean {
            return true;
        }
        
        public method activate(Args args){
            PlayerData p = 0;
            if (args.size() != 0) return;
            p = PlayerData.get(GetTriggerPlayer());
            
            if (PlayerDataPick.initialized() &&
                !PlayerDataPick[p].isRandoming() &&
                !PlayerDataPick[p].hasPicked()){
                PlayerDataPick[p].setRandoming(true);
                p.say("|cff00bfffLazy Man's Random has been |r|cffff0000enabled|r|cff00bfff. " + 
                      "Sit back and grab a beer while the game clicks the random button for you.|r");
					
				// 0104 - Idea from RipDog to disable tip messages if you use the lazy random command!
				p.disableTips();
                
                // Auto pick if possible.
                if (PlayerDataPick[p].canPick()) {
                    PlayerDataPick[p].pick(p.race());
                }
                
                if (GetLocalPlayer() == p.player()){
                    PlaySoundBJ(gg_snd_Builder_Yes);
                }
            }
        }
    }
}
//! endzinc