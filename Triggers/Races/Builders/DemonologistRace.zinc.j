//! zinc

library DemonologistRace requires Races {
    public struct DemonologistRace extends DefenderRace {
        method toString() -> string {
            return "Demonologist";
        }
        
        method widgetId() -> integer {
            return 'u00I';
        }
		
		method isWidgetId(integer id) -> boolean {
			return id == this.widgetId() || id == 'u00N'; // Enhanced Form
		}

        method itemId() -> integer {
            return 'I00S';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNDoomGuard.blp";
        }
        
        method onSpawn(unit u){
			// Spell Book
			UnitMakeAbilityPermanent(u, true, 'A05P');
			UnitMakeAbilityPermanent(u, true, 'A074');
			UnitMakeAbilityPermanent(u, true, 'A07A');
			UnitMakeAbilityPermanent(u, true, 'A07D');
			UnitMakeAbilityPermanent(u, true, 'A07R');
			UnitMakeAbilityPermanent(u, true, 'A07Q');
			UnitMakeAbilityPermanent(u, true, 'A07P');
			UnitMakeAbilityPermanent(u, true, 'A0GT');
			UnitMakeAbilityPermanent(u, true, 'A07S');
			UnitMakeAbilityPermanent(u, true, 'A07T');
			UnitMakeAbilityPermanent(u, true, 'A02N');
        }

        method difficulty() -> real {
            return 3.0;
        }
        
        method setupTech(player p) {
			// Ultimate Towers
            SetPlayerTechMaxAllowed(p, 'o03S', -1);
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