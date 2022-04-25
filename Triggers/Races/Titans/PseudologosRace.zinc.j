//! zinc

library PseudologosRace requires Races {
    public struct PseudologosRace extends TitanRace {
		private TitanRace minion = 0;
        method toString() -> string {
            return "Pseudologos";
        }
        
        method widgetId() -> integer {
            return 'E016';
        }
        
        method childId() -> integer {
            return minion.childId();
        }

        method itemId() -> integer {
            return 0;
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNKiljaedin.blp";
        }

        method childIcon() -> string {
            return minion.childIcon();
        }
		
		method onSpawn(unit u) {
			CustomTitanRace r = 0;
			string abilities = "QWERSDF";
            integer i = 0;
            string indexS = "";
			TitanRace tRace = 0;
			
			while (minion == 0 || minion == this) {
				minion = TitanRace.random();
			}
			
			for (0 <= i < StringLength(abilities)) {
				tRace = 0;
                indexS = SubString(abilities, i, 1 + i);
				// Reroll Bubonicus and Demonicus' Ultimate and Terminus' Unique
				while (tRace == 0 || tRace == this || 
					   tRace.toString() == "Bubonicus" || 
					   (indexS == "F" && tRace.toString() == "Demonicus") ||
					   (indexS == "R" && tRace.toString() == "Terminus")) {
					tRace = TitanRace.random();
				}
				
				r.addTitanAbility(tRace, indexS);
				
				if (indexS == "D" && tRace.toString() == "Glacious") {
					CurrentTap.begin(u);
				}
            }
			
			r.onSpawn(u);
			r.destroy();
		}
        
        method inRandomPool() -> boolean {
			// NOTE(rory): Pseudologos disabled for the time being
            return false;
        }
		
        private static method create() -> thistype {
            return thistype.allocate();
        }
        
        private static method onInit(){
            super.register(thistype.create());
        }
    }
}

//! endzinc