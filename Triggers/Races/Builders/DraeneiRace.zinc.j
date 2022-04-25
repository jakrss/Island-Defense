//! zinc

library DraeneiRace requires Races {
    public struct DraeneiRace extends DefenderRace {
        method toString() -> string {
            return "Draenei";
        }
        
        method widgetId() -> integer {
            return 'u00W';
        }

        method itemId() -> integer {
            return 'I03Y';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNDranaiMage.blp";
        }

        method difficulty() -> real {
            return 2.0;
        }

        method childId() -> integer {
            return 'H040'; // Hunter
        }
		
		method isChildId(integer id) -> boolean {
            return this.childId() == id || id == 'H03Z'; // Hunter
        }

        method childItemId() -> integer {
            return 'q135'; // Hunter Research
        }
		
		method setupTech(player p) {
			// Ultimate Towers
            SetPlayerTechMaxAllowed(p, 'o02A', -1);
            SetPlayerTechMaxAllowed(p, 'o02E', -1);
		}
        
        method onSpawn(unit u) {
            IssueImmediateOrderById(u, 852589);     // Draenei Mana Shield
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