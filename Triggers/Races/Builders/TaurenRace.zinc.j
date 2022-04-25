//! zinc

library TaurenRace requires Races {
    public struct TaurenRace extends DefenderRace {
        method toString() -> string {
            return "Tauren";
        }
        
        method widgetId() -> integer {
            return 'O01Q';
        }
		
		method isWidgetId(integer id) -> boolean {
			return id == this.widgetId() || id == 'O01R'; // Ancestral Form
		}

        method itemId() -> integer {
            return 'I02X';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNSpiritWalker.blp";
        }

        method difficulty() -> real {
            return 2.0;
        }
		
		method setupTech(player p) {
			// Ultimate Towers
            SetPlayerTechMaxAllowed(p, 'o01U', -1);
		}

        method onSpawn(unit u){
            SelectHeroSkill(u, 'A0AD' );                // Ancestral
            UnitMakeAbilityPermanent(u, true, 'A0AE');  // Spellbook
            UnitMakeAbilityPermanent(u, true, 'A0AR');
            UnitMakeAbilityPermanent(u, true, 'A0AO');
            UnitMakeAbilityPermanent(u, true, 'A0AK');
            UnitMakeAbilityPermanent(u, true, 'A0AQ');
            UnitMakeAbilityPermanent(u, true, 'A0AL');
            UnitMakeAbilityPermanent(u, true, 'A0AF');
            UnitMakeAbilityPermanent(u, true, 'A0AB');
            UnitMakeAbilityPermanent(u, true, 'A0AT');
            UnitMakeAbilityPermanent(u, true, 'A0BD');
            UnitMakeAbilityPermanent(u, true, 'A04F');
            //UnitMakeAbilityPermanent(u, true, 'A0D2'); // Attunement
            UnitMakeAbilityPermanent(u, true, 'A0AG');
            UnitMakeAbilityPermanent(u, true, 'A0AC');
	    UnitMakeAbilityPermanent(u, true, 'A061');
	    UnitMakeAbilityPermanent(u, true, 'A0MU');
	    UnitMakeAbilityPermanent(u, true, 'A0JH');
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