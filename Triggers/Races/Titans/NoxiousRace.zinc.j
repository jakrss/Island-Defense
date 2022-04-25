//! zinc

library SypheriousRace requires Races {
    public struct SypheriousRace extends TitanRace {
        method toString() -> string {
            return "Noxious";
        }
        
        method widgetId() -> integer {
            return 'E00B';
        }
        
        method childId() -> integer {
            return 'U001';
        }

        method itemId() -> integer {
            return 'I02H';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNHydra.blp";
        }

        method childIcon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNGreenHydra.blp";
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