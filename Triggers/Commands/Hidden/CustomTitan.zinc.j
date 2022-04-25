//! zinc

library CustomTitanTweak requires TweakManager {
    public struct CustomTitanTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Custom Titan";
        }
        public method shortName() -> string {
            return "CUSTOM";
        }
        public method description() -> string {
            return "Customize a Titan to your liking!\nUsage: -custom TMSDQWERF (where each character is the first letter of the Titan's name)";
        }
        public method command() -> string {
            return "-custom";
        }
        public method hidden() -> boolean {
            return true;
        }
        
        private method customRace(PlayerData p, string racestring) -> CustomTitanRace {
            CustomTitanRace cRace = CustomTitanRace.sneakyCreate();
            TitanRace r = TitanRace.fromName("Lucidious");
			integer i = 0;
			string abilities = "TMSDQWERF";
			string indexS = "";
			string indexA = "";
			
            cRace.setTitanName("Customicus");
			
			for (0 <= i < StringLength(abilities)) {
				if (StringLength(racestring) > i) {
					indexS = SubString(racestring, i, i + 1);
				}
				else {
					indexS = "L";
				}
				
				// Bubonicus is banned from Customicus, default to Lucidious
				if (indexS == "B") {
					p.say("Unfortunately, Bubonicus' abilities are currently unavailable to be used.");
					indexS = "L";
				}
				
				// Get race using index
				r = TitanRace.fromNamePartial(indexS, false);
				
				// If getting a race failed, default to Lucidious
				if (r == 0) r = TitanRace.fromName("Lucidious");
				
				
				
				// This is the ability index (Q, W, etc.)
				indexA = SubString(abilities, i, i + 1);
				
				// Set TitanBase and Minion to the Slow Poison effect (?)
				if (indexA == "T") {
					cRace.setTitanBase(r);
				}
				else if (indexA == "M") {
					cRace.setMinion(r);
				}
				else if (indexA == "S") {
					// Force slow to be the same as the Minion chosen... to prevent slow stacking
					cRace.addTitanAbility(cRace.minionRace(), indexA);
				}
				else {
					cRace.addTitanAbility(r, indexA);
				}
			}
            
            // cRace.printAbilityNames();
            
            // Don't destroy other bases
            return cRace;
        }
        
        public method activate(Args args){
            PlayerData p = 0;
            PlayerDataPick pPick = 0;
			CustomTitanRace r = 0;
			string str = "";
            if (args.size() != 1) return;
            p = PlayerData.get(GetTriggerPlayer());
			
			if (!GameSettings.getBool("DEBUG") && p.name() != GameSettings.getStr("EDITOR")) return;
			
			str = args[0].getStr();

            if (PlayerDataPick.initialized()) {
                pPick = PlayerDataPick[p];
                if (!pPick.isRandoming() &&
                    !pPick.hasPicked()){
					r = this.customRace(p, str);
                    pPick.pick(r);
                }
            }
        }
    }
}
//! endzinc