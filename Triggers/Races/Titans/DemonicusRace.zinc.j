//! zinc

library DemonicusRace requires Races, CustomTitanRace {
    public struct DemonicusRace extends TitanRace {
        method toString() -> string {
            return "Demonicus";
        }
        
        method inRandomPool() -> boolean {
            return true;
        }
        
        method widgetId() -> integer {
            return 'E00E';
        }
        
        method childId() -> integer {
            return 'U005';
        }

        method itemId() -> integer {
            return 'I02K';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNVoidWalker.blp";
        }

        method childIcon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNVoidwalker2.blp";
        }
        
        method onSpawn(unit u) {
            PlayerData p = PlayerData.get(GetOwningPlayer(u));
            
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