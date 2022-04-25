//! zinc

library BubonicusRace requires Races, CustomTitanRace {
    public struct BubonicusRace extends TitanRace {
        method toString() -> string {
            return "Bubonicus";
        }
        
        method widgetId() -> integer {
            return 'E00I';
        }
        
        method childId() -> integer {
            return 'U00B';
        }

        method itemId() -> integer {
            return 'I02M';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNAbomination.blp";
        }

        method childIcon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNDalaranMutant.blp";
        }
        
        method onSpawn(unit u){
			// CustomTitanRace.setBaseAbilities(u, this.toString());
            // Add corpse spawning to gold mound
            UnitAddAbility(UnitManager.TITAN_SPELL_WELL, 'A044');
            Bubonicus[u].count(); // Force this Bubonicus struct to be created
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