//! zinc

library ArachnidRace requires Races {
    public struct ArachnidRace extends DefenderRace {
        method toString() -> string {
            return "Arachnid";
        }

        method inRandomPool() -> boolean {
            return false;
        }
        
        method widgetId() -> integer {
            return 'h03D';
        }

        method itemId() -> integer {
            return 'I08F';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNSpiderBlack.blp";
        }

        method difficulty() -> real {
            return 2.0;
        }

        method childId() -> integer {
            return 'H04U'; // Hunter
        }
		
		method setupTech(player p) {
			// Ultimate Towers
            SetPlayerTechMaxAllowed(p, 'o00Q', -1);
            SetPlayerTechMaxAllowed(p, 'o02R', -1);
            SetPlayerTechMaxAllowed(p, 'o02Z', -1);
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