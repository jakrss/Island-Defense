//! zinc

library NatureRace requires Races {
    public struct NatureRace extends DefenderRace {
        method toString() -> string {
            return "Nature";
        }
        
        method widgetId() -> integer {
            return 'h00Q';
        }

        method itemId() -> integer {
            return 'I02B';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNAncientOfLore.blp";
        }

        method difficulty() -> real {
            return 3.0;
        }

        method childId() -> integer {
            return 'H00S'; // Hunter
        }

        method childItemId() -> integer {
            return 'q050'; // Hunter Research
        }
		
		method setupTech(player p) {
			// Ultimate Towers
            SetPlayerTechMaxAllowed(p, 'o00R', -1);
            SetPlayerTechMaxAllowed(p, 'o00T', -1);
            SetPlayerTechMaxAllowed(p, 'o00S', -1);
            SetPlayerTechMaxAllowed(p, 'o024', -1);
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