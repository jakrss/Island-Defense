//! zinc

library SatyrRace requires Races {
    public struct SatyrRace extends DefenderRace {
        method toString() -> string {
            return "Satyr";
        }
        
        method inRandomPool() -> boolean {
            return false;
        }
        
        method isPickable() -> boolean {
            return true;
        }
        
        method widgetId() -> integer {
            return 'h035';
        }

        method itemId() -> integer {
            return 'I033';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNSatyrTrickster.blp";
        }

        method difficulty() -> real {
            return 3.0;
        }
		
		method setupTech(player p) {
			// Ultimate Towers
            SetPlayerTechMaxAllowed(p, 'e00Y', -1);
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