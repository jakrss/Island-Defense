//! zinc

library FaerieRace requires Races {
    public struct FaerieRace extends DefenderRace {
        method toString() -> string {
            return "Faerie";
        }
        
        method widgetId() -> integer {
            return 'h02S';
        }
		
		method isWidgetId(integer id) -> boolean {
			return id == this.widgetId() || id == 'h004'; // Enhanced Form
		}

        method itemId() -> integer {
            return 'I02W';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNFaerieDragon.blp";
        }

        method difficulty() -> real {
            return 3.0;
        }
        
        method setupTech(player p) {
			// Ultimate Towers
            SetPlayerTechMaxAllowed(p, 'o017', -1);
            SetPlayerTechMaxAllowed(p, 'o01P', -1);
            SetPlayerTechMaxAllowed(p, 'o00O', -1);
		}
		
        method onSpawn(unit u) {
			UnitMakeAbilityPermanent(u, true, 'A0A4');	// Enchanted Ledger
			UnitMakeAbilityPermanent(u, true, 'A05K');	// Phase Shift
			UnitMakeAbilityPermanent(u, true, 'A0A0');	// Inner Fire
			UnitMakeAbilityPermanent(u, true, 'A0A6');	// Faerie Fire
			UnitMakeAbilityPermanent(u, true, 'A09Z');	// Silence
			UnitMakeAbilityPermanent(u, true, 'A05M');	// Energy Charge
			UnitMakeAbilityPermanent(u, true, 'A079');	// Cripple
			UnitMakeAbilityPermanent(u, true, 'A07C');	// Death Shield
			UnitMakeAbilityPermanent(u, true, 'A0AA');	// Enchanted Faerie Attack
			UnitMakeAbilityPermanent(u, true, 'A05X');	// Mana Flare
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