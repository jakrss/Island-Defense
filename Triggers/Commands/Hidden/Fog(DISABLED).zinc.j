//! zinc

library FogCommand requires TweakManager {
    public struct FogCommand extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Fog";
        }
        public method shortName() -> string {
            return "FOG";
        }
        public method description() -> string {
            return "Customize your fog style.";
        }
        public method command() -> string {
            return "-fog";
        }
        public method hidden() -> boolean {
            return true;
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
			integer style = args[0].getInt();
			real zStart = args[1].getReal();
			real zEnd = args[2].getReal();
			real density = args[3].getReal();
			real red = args[4].getReal();
			real green = args[5].getReal();
			real blue = args[6].getReal();
			
			if (GetLocalPlayer() == p.player()) {
				SetTerrainFogEx(style, zStart, zEnd, density, red, green, blue);
			}
        }
    }
}
//! endzinc