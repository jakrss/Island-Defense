//! zinc

library DefenderUnit requires Unit {
    public struct DefenderUnit extends Unit {
        private unit mUnit = null;
        private integer mClass = 0;
        private Race mRace = 0;
        private PlayerData mOwner = 0;
        
        public method unit() -> unit {
            return this.mUnit;
        }
        public method class() -> integer {
            return this.mClass;
        }
        public method race() -> Race {
            return this.mRace;
        }
        public method owner() -> PlayerData {
            PlayerData data = 0;
            if (this.mUnit != null){
                data = PlayerData.get(GetOwningPlayer(this.mUnit));
                return data;
            }
            return this.mOwner;
        }
        
        public static method create(PlayerData p) -> thistype {
            thistype this = 0;
            if (p.class() != PlayerData.CLASS_DEFENDER){
                Game.say("ERROR - " + p.nameColored() + " tried to create DefenderUnit but isn't CLASS_DEFENDER");
                return this;
            }
            this = thistype.allocate();
            this.mClass = p.class();
            this.mRace = PlayerData.CLASS_DEFENDER;
            this.mOwner = p;
            
            return this;
        }
		
	public static method prepare(PlayerData p) {
			player q = p.player();
			
            SetPlayerTechMaxAllowed(q, 'HERO', 1); // Max one Hero
			
			// All of this Upgrade System shit should be moved somewhere else......................................................
            SetPlayerTechMaxAllowed(q, 'h03R', 0); // Disable Troll's Workers
            SetPlayerTechMaxAllowed(q, 'h005', 0); // Disable Goblin's Advanced Walls
            SetPlayerTechMaxAllowed(q, 'o027', 0); // Disable Gnolls's Deadly Mega Axe Towers
			SetPlayerTechMaxAllowed(q, 'o010', 0); // Disable Goblin's Enhanced Factories
			SetPlayerTechMaxAllowed(q, 'o011', 0); // Disable Faerie's Enhanced Pools
			SetPlayerTechMaxAllowed(q, 'o012', 0); // Disable Ogre's Enhanced Catapult
			SetPlayerTechMaxAllowed(q, 'o019', 0); // Disable Ogre's Super Catapult
			SetPlayerTechMaxAllowed(q, 'o01E', 0); // Disable Ogre's Mega Catapult
			SetPlayerTechMaxAllowed(q, 'o024', 0); // Disable Feral Fruit Trees
            SetPlayerTechMaxAllowed(q, 'R034', 0); // Disable Ogre's damage research until R033 is researched
            
            //Setup Panda tech, disabling lightning towers 
            //and other stuff
            SetPlayerTechMaxAllowed(q, 'o02U', 0);
            SetPlayerTechMaxAllowed(q, 'o02V', 0);
            SetPlayerTechMaxAllowed(q, 'o02X', 0);
            SetPlayerTechMaxAllowed(q, 'o02Y', 0);
            SetPlayerTechMaxAllowed(q, 'h03E', 0);
			
            SetPlayerAbilityAvailable(q, 'A00R', false); // Disable Energy Charge spellbook
			SetPlayerAbilityAvailable(q, 'Aro1', false); // Disable Root
			SetPlayerAbilityAvailable(q, '&tru', false); // Disable True Strike spellbook
            
            
            // Disable Ultimate Towers
            SetPlayerTechMaxAllowed(q, 'e00Y', 0);
            SetPlayerTechMaxAllowed(q, 'h00P', 0);
            SetPlayerTechMaxAllowed(q, 'n01J', 0);
            SetPlayerTechMaxAllowed(q, 'n01K', 0);
            SetPlayerTechMaxAllowed(q, 'n01L', 0);
            SetPlayerTechMaxAllowed(q, 'o003', 0);
            SetPlayerTechMaxAllowed(q, 'o005', 0);
            SetPlayerTechMaxAllowed(q, 'o006', 0);
            SetPlayerTechMaxAllowed(q, 'o007', 0);
            SetPlayerTechMaxAllowed(q, 'o00J', 0);
            SetPlayerTechMaxAllowed(q, 'o00K', 0);
            SetPlayerTechMaxAllowed(q, 'o00L', 0);
            SetPlayerTechMaxAllowed(q, 'o00M', 0);
            SetPlayerTechMaxAllowed(q, 'o00N', 0);
            SetPlayerTechMaxAllowed(q, 'o00O', 0);
            SetPlayerTechMaxAllowed(q, 'o00P', 0);
            SetPlayerTechMaxAllowed(q, 'o00Q', 0);
            SetPlayerTechMaxAllowed(q, 'o00R', 0);
            SetPlayerTechMaxAllowed(q, 'o00S', 0);
            SetPlayerTechMaxAllowed(q, 'o00T', 0);
            SetPlayerTechMaxAllowed(q, 'o015', 0);
            SetPlayerTechMaxAllowed(q, 'o016', 0);
            SetPlayerTechMaxAllowed(q, 'o017', 0);
            SetPlayerTechMaxAllowed(q, 'o01P', 0);
            SetPlayerTechMaxAllowed(q, 'o01U', 0);
            SetPlayerTechMaxAllowed(q, 'o01V', 0);
            SetPlayerTechMaxAllowed(q, 'o01Y', 0);
            SetPlayerTechMaxAllowed(q, 'o02A', 0);
            SetPlayerTechMaxAllowed(q, 'o02E', 0);
            SetPlayerTechMaxAllowed(q, 'o02P', 0);
            SetPlayerTechMaxAllowed(q, 'o02Q', 0);
            SetPlayerTechMaxAllowed(q, 'o02R', 0);
            SetPlayerTechMaxAllowed(q, 'o03C', 0);
            SetPlayerTechMaxAllowed(q, 'o03N', 0);
	    SetPlayerTechMaxAllowed(q, 'o02Z', 0);
	    SetPlayerTechMaxAllowed(q, 'o03S', 0);
	//Hunter limit of 1 per player
	    SetPlayerTechMaxAllowed(q, 'H03Z', 1); //Draenei Hunter
	    SetPlayerTechMaxAllowed(q, 'H02L', 1); //Dryad Hunter
	    SetPlayerTechMaxAllowed(q, 'H00O', 1); //Gnoll Hunter
	    SetPlayerTechMaxAllowed(q, 'H00Z', 1); //Goblin Hunter
	    SetPlayerTechMaxAllowed(q, 'H00N', 1); //Makrura Hunter
	    SetPlayerTechMaxAllowed(q, 'H04K', 1); //Murloc Hunter
	    SetPlayerTechMaxAllowed(q, 'H00S', 1); //Nature Hunter
	    SetPlayerTechMaxAllowed(q, 'H039', 1); //Ogre Hunter
	    SetPlayerTechMaxAllowed(q, 'H046', 1); //Pirate Hunter
	    SetPlayerTechMaxAllowed(q, 'H020', 1); //Rad Hunter
	    SetPlayerTechMaxAllowed(q, 'H00M', 1); //Troll Hunter
	    SetPlayerTechMaxAllowed(q, 'H04U', 1); //Arachnid Hunter
			
			// Setup Race-specific Tech
			if (p.race() != 0) {
				p.race().setupTech(q);
			}
		}
		
		public method spawn(real x, real y, real rotation) -> unit {
            this.mUnit = CreateUnit(this.mOwner.player(), this.mOwner.race().widgetId(), x, y, rotation);
			return this.mUnit;
		}
    }
    
    public struct DefenderDeath {
        public static method onDeath(DefenderUnit u, unit killer){
			Game.mode().onDefenderDeath(u, killer);
        }
    }
}

//! endzinc