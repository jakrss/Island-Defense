//! zinc

library FossuriousRace requires Races {
    public struct FossuriousRace extends TitanRace {
        method toString() -> string {
            return "Fossurious";
        }
        
        method widgetId() -> integer {
            return 'E012'; // E015 (burrowed)
        }
        
        method childId() -> integer {
            return 'U016';
        }

        method itemId() -> integer {
            return 'I03X';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNHeroCryptLord.blp";
        }

        method childIcon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNNagaMyrmidonRoyalGuard.blp";
        }
		
		method onSpawn(unit u) {
			CustomTitanRace.setBaseAbilities(u, this.toString());
		}
        
        method inRandomPool() -> boolean {
            return false;
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