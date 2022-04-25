//! zinc

library MolteniousRace requires Races {
    public struct MolteniousRace extends TitanRace {
        method toString() -> string {
            return "Moltenious";
        }
        
        method widgetId() -> integer {
            return 'E00C';
        }
        
        method childId() -> integer {
            return 'U003';
        }

        method itemId() -> integer {
            return 'I02I';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNHeroAvatarOfFlame.blp";
        }
        
        method childIcon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNInfernal.blp";
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