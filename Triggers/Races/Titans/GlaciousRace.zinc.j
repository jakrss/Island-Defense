//! zinc

library GlaciousRace requires Races, CustomTitanRace {
    public struct GlaciousRace extends TitanRace {
        method toString() -> string {
            return "Glacious";
        }
        
        method widgetId() -> integer {
            return 'E00J';
        }
        
        method childId() -> integer {
            return 'U00D';
        }

        method itemId() -> integer {
            return 'I00R';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNArchimonde.blp";
        }

        method childIcon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNWendigo.blp";
        }
		
		method onSpawn(unit u) {
			// CustomTitanRace.setBaseAbilities(u, this.toString());
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