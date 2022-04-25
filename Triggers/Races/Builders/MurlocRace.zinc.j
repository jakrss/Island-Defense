//! zinc

library MurlocRace requires Races {
    public struct MurlocRace extends DefenderRace {
        method toString() -> string {
            return "Murloc";
        }
        
        method widgetId() -> integer {
            return 'h04I';
        }

        method itemId() -> integer {
            return 'I012';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNMurgalSlave.blp";
        }

        method difficulty() -> real {
            return 1.0;
        }

        method childId() -> integer {
            return 'H04K'; // Hunter
        }

        method childItemId() -> integer {
            return 'q088'; // Hunter Research
        }
		
		method setupTech(player p) {
			// Ultimate Towers
            SetPlayerTechMaxAllowed(p, 'o006', -1);
            SetPlayerTechMaxAllowed(p, 'o007', -1);
            SetPlayerTechMaxAllowed(p, 'o005', -1);
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