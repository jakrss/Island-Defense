//! zinc

library VoltronRace requires Races {
    public struct VoltronRace extends TitanRace {
        method toString() -> string {
            return "Voltron";
        }
        
        method widgetId() -> integer {
            return 'E00K';
        }
        
        method childId() -> integer {
            return 'U00L';
        }

        method itemId() -> integer {
            return 'I02L';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNDeepLordRevenant.blp";
        }

        method childIcon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNRevenant.blp";
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