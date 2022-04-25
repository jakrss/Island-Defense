//! zinc

library PandaRace requires Races {
    public struct PandaRace extends DefenderRace {
        method toString() -> string {
            return "Panda";
        }
        
        method inRandomPool() -> boolean {
            return false;
        }
        
        method widgetId() -> integer {
            return 'h02D';
        }


        method itemId() -> integer {
            return 'I03T';
        }
        
        method IsWidgetId(integer id) -> boolean {
            return id=='h02D' || id== 'h02N' || id=='ho2M' || id=='h02K';
        }

        method icon() -> string {
            return "ReplaceableTextures\\CommandButtons\\BTNPandarenBrewmaster.blp";
        }

        method difficulty() -> real {
            return 3.0;
        }
	
        method onSpawn(unit u) {
            UnitMakeAbilityPermanent(u,true,'A0GR'); // Wind Walk (Storm Form)
            UnitMakeAbilityPermanent(u,true,'A0FA'); // Earth Transformation
            UnitMakeAbilityPermanent(u,true,'A0B1'); // Fire Transformation
            UnitMakeAbilityPermanent(u,true,'A0F8'); // Storm Transformation
            UnitMakeAbilityPermanent(u,true,'A0JG'); // Skystrike (Storm Form)
            UnitMakeAbilityPermanent(u,true,'A0FO'); // Enflame (Fire Form)
            UnitMakeAbilityPermanent(u,true,'A0GJ'); // Fire Transform
            UnitMakeAbilityPermanent(u,true,'A0GO'); // Air Servants (Storm Form)
            UnitMakeAbilityPermanent(u,true,'A0GC'); // Elementalize
            UnitMakeAbilityPermanent(u,true,'S005'); // Fleetfoot (Storm Form)
            UnitMakeAbilityPermanent(u,true,'A0GS'); // Mark of the Wind (Storm Form)
            UnitMakeAbilityPermanent(u,true,'A0GI'); // Essence Collection
        }
        
	method setupTech(player p) {
	    // Ultimate Towers
            SetPlayerTechMaxAllowed(p, 'o021', -1);
	    SetPlayerTechMaxAllowed(p, 'e01O', -1);
	    SetPlayerTechMaxAllowed(p, 'o01Z', 0);
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