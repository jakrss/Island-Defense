//! zinc

library RadioactiveRace requires Races {
    public struct RadioactiveRace extends DefenderRace {
        method toString() -> string {
            return "Radioactive";
        }
        
        method widgetId() -> integer {
            return 'u009';
        }

        method itemId() -> integer {
            return 'I028';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNInfernalStone.blp";
        }

        method difficulty() -> real {
            return 2.0;
        }

        method childId() -> integer {
            return 'H020'; // Hunter
        }

        method childItemId() -> integer {
            return 'q092'; // Hunter Research
        }
		
		method setupTech(player p) {
			// Ultimate Towers
            SetPlayerTechMaxAllowed(p, 'o015', -1);
            SetPlayerTechMaxAllowed(p, 'h00P', -1);
            SetPlayerTechMaxAllowed(p, 'o016', -1);
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