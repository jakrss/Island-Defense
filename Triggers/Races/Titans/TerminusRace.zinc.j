//! zinc

library TerminusRace requires Races, StringLib {
    public struct TerminusRace extends TitanRace {
		private string name = "Granitacles";
        method toString() -> string {
            return this.name;
        }
        
        method widgetId() -> integer {
            return 'E00O';
        }
        
        method childId() -> integer {
            return 'U00O';
        }

        method itemId() -> integer {
            return 'I02J';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNMountainGiant.blp";
        }

        method childIcon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNAncientOfWonders.blp";
        }
		
		method onSpawn(unit u) {
			// CustomTitanRace.setBaseAbilities(u, this.toString());
			
			// Fancy name switch
			if (StringIndexOf(GetHeroProperName(u), "Gran", false) != STRING_INDEX_NONE) {
				this.name = "Granitacles";
			}
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