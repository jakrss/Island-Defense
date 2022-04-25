//! zinc

library LucidiousRace requires Races, CustomTitanRace {
    public struct LucidiousRace extends TitanRace {
        method toString() -> string {
            return "Lucidious";
        }
        
        method widgetId() -> integer {
            return 'E01D';
        }
        
        method childId() -> integer {
            return 'U016';
        }

        method itemId() -> integer {
            return 'I02G';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNNagaMyrmidon.blp";
        }

        method childIcon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNNagaMyrmidonRoyalGuard.blp";
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