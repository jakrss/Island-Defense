//! zinc

library BreezeriousRace requires Races, StringLib {
    public struct BreezeriousRace extends TitanRace {
        method toString() -> string {
            return "Breezerious";
        }
        
        method widgetId() -> integer {
            return 'E011';
        }
        
        method childId() -> integer {
            return 'U00Y';
        }

        method itemId() -> integer {
            return 'I02U';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNNetherDragon.blp";
        }

        method childIcon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNNetherDragon.blp";
        }
		
		method onSpawn(unit u) {
			/*CustomTitanRace.setBaseAbilities(u, this.toString());
			
			// Fancy name switch
			if (StringIndexOf(GetHeroProperName(u), "Bree", false) != STRING_INDEX_NONE) {
				this.name = "Breezerious";
			}*/
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