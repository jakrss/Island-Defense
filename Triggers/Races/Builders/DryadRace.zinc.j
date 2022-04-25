//! zinc

library DryadRace requires Races {
    public struct DryadRace extends DefenderRace {
        method toString() -> string {
            return "Dryad";
        }
        
        method widgetId() -> integer {
            return 'h01T';
        }

        method itemId() -> integer {
            return 'I066';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNDryad.blp";
        }

        method difficulty() -> real {
            return 1.0;
        }

        method childId() -> integer {
            return 'H02L'; // Hunter
        }

        method childItemId() -> integer {
            return 'q216'; // Hunter Research
        }
		
        method setupTech(player p) {
			// Ultimate Towers
            SetPlayerTechMaxAllowed(p, 'o00S', -1);
            SetPlayerTechMaxAllowed(p, 'o03C', -1);
            SetPlayerTechMaxAllowed(p, 'o00Q', -1);
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