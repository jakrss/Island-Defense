
//! textmacro GenerateCustomConversionAbilities takes TITANID
	//! externalblock extension=lua ObjectMerger $FILENAME$
	//! i function createAbility(titanId)
	//! i   setobjecttype("abilities")
	//! i   str = "QWERF"
	//! i   for i = 1, string.len(str) do
	//! i     local abilId = string.sub(str, i, i)
	///! i     local spellbookId = "T" .. titanId .. "V" .. abilId
	//! i     local converterId = "T" .. titanId .. "U" .. abilId
	//! i     local baseId = "TCA" .. abilId
	//! i     local abilityId = "T" .. titanId .. "A" .. abilId
	//! i     createobject("ANeg", converterId)
	//! i     if (currentobject() ~= "") then
	//! i       makechange(current, "alev", 1)
	//! i       makechange(current, "aart", "")
	//! i       makechange(current, "Neg3", 1, baseId .. "," .. abilityId)
	//! i       makechange(current, "Neg4", 1, "_")
	//! i       makechange(current, "Neg5", 1, "_")
	//! i       makechange(current, "Neg6", 1, "_")
	//! i       makechange(current, "Neg2", 1, 0.00)
	//! i       makechange(current, "Neg1", 1, 0.00)
	//! i       makechange(current, "aher", 0)
	//! i       makechange(current, "arac", "undead")
	//! i       makechange(current, "ansf", "(Customicus)")
	//! i       makechange(current, "anam", baseId .. " -> " .. abilityId)
	//! i       makechange(current, "atp1", 1, " ")
	//! i       makechange(current, "aub1", 1, " ")
	//! i     end
	///! i     createobject("Aspb", spellbookId)
	///! i     if (currentobject() ~= "") then
	///! i       makechange(current, "spb4", 1, 1)
	///! i       makechange(current, "spb3", 1, 1)
	///! i       makechange(current, "spb1", 1, converterId)
	///! i       makechange(current, "aite", 0)
	///! i       makechange(current, "arac", "undead")
	///! i       makechange(current, "ansf", "(Customicus)")
	///! i       makechange(current, "anam", abilityId .. " Spell Book")
	///! i     end
	//! i   end
	//! i end
    //! i createAbility("$TITANID$")
	//! endexternalblock
//! endtextmacro

/*
//! runtextmacro GenerateCustomConversionAbilities("D")
//! runtextmacro GenerateCustomConversionAbilities("G")
//! runtextmacro GenerateCustomConversionAbilities("L")
//! runtextmacro GenerateCustomConversionAbilities("M")
//! runtextmacro GenerateCustomConversionAbilities("S")
//! runtextmacro GenerateCustomConversionAbilities("V")
//! runtextmacro GenerateCustomConversionAbilities("B")
//! runtextmacro GenerateCustomConversionAbilities("T")
*/
//! zinc

library CustomTitanRace requires Races, Ascii {
    public struct CustomTitanRace extends TitanRace {
        module TitanRaceModule;
        
        private string mName = "Customicus";
        private integer mWidgetId = 0;
        private string mIcon = "";
		private TitanRace mMinion = 0;
		
		method minionRace() -> TitanRace {
			return this.mMinion;
		}
        
        method setTitanName(string n) {
            this.mName = n;
        }
        
        method setTitanBase(TitanRace r) {
            this.mWidgetId = r.widgetId();
            this.mIcon = r.icon();
        }
        
        public static method clearRaceAbilities(unit u, TitanRace r) {
            string abilities = "QWERSDF0123456789";
            integer i = 0;
            integer index = 0;
            string indexS = "";
            for (0 <= i < StringLength(abilities)) {
                indexS = SubString(abilities, i, 1 + i);
                index = S2A("T" + SubString(r.toString(), 0, 1) + "A" + indexS);
                if (GetUnitAbilityLevel(u, index) > 0) {
                    UnitRemoveAbility(u, index);
                }
            }
        }
        
        method clearAbilities(){
            this.abilityTable.flush();
        }
        
        // T<titan name>A<abilitycode>
        method addTitanAbility(TitanRace r, string loc) {
            string abil = "T";
            integer abilityId = 0;
            abil += SubString(r.toString(), 0, 1);
            abil += "A";
            abil += loc;
            
            abilityId = S2A(abil);
            
            // Add or override ability
            this.abilityTable.integer[StringHash(loc)] = abilityId;
        }
        
        method addTitanNuke(TitanRace r) {
            this.addTitanAbility(r, "Q");
        }
        
        method setMinion(TitanRace r) {
			this.mMinion = r;
        }
        
        method toString() -> string {
            return this.mName;
        }
        
        method widgetId() -> integer {
            return this.mWidgetId;
        }
        
        method childId() -> integer {
            return this.mMinion.childId();
        }

        method itemId() -> integer {
            return 0; // No item ID
        }

        method icon() -> string {
            return this.mIcon;
        }

        method childIcon() -> string {
            return this.mMinion.childIcon();
        }

		static method setBaseAbilities(unit u, string titan) {
			// NOTE(rory): Currently a weird bug where items can flip out when using this
            string abilities = "QWERSDF";
            integer i = 0;
            string indexS = "";
            integer id = 0;
			string titanId = "";
			player p = GetOwningPlayer(u);
			real y = 0.0;
			for (0 <= i < StringLength(abilities)) {
				titanId = SubString(titan, 0, 1);
                indexS = SubString(abilities, i, 1 + i);
				id = S2A("T" + titanId + "A" + indexS);
				if (indexS == "S" ||
					indexS == "D") {
					UnitAddAbility(u, id); // Add innate abilities
				}
				else {
					titanId = SubString(A2S(id), 1, 2);
					id = S2A("T" + titanId + "U" + indexS);
					SetPlayerAbilityAvailable(p, id, false);
					UnitAddAbility(u, id);
				}
            }
		}
		
		static method setupAbilities() {
			string abilities = "QWERSDF0123456789";
            integer i = 0, j = 0, k = 0;
            integer id = 0;
            string indexS = "";
			string titanId = "";
            
            for (0 <= i < StringLength(abilities)) {
                indexS = SubString(abilities, i, 1 + i);
                
				for (0 <= j < TitanRace.count()) {
					titanId = SubString(TitanRace[j].toString(), 0, 1);
					id = S2A("T" + titanId + "U" + indexS);
					for (0 <= k < 12) {
						SetPlayerAbilityAvailable(Player(k), id, false);
					}
                }
            }
		}
        
        method onSpawn(unit u) {
            // Add abilities to names!
            string abilities = "QWERSDF0123456789";
            integer i = 0;
            integer index = 0;
            string indexS = "";
            integer id = 0;
            real y = 0.0;
			player p = GetOwningPlayer(u);
			string titanId = "";
            
            // First remove original abilities
			// This won't work as Hero abilities cannot be removed...
            //thistype.clearRaceAbilities(u, TitanRace.fromWidgetId(this.widgetId()));
            
            for (0 <= i < StringLength(abilities)) {
                indexS = SubString(abilities, i, 1 + i);
                index = StringHash(indexS);
                if (this.abilityTable.has(index)) {
                    id = this.abilityTable[index];
                    if (id != 0) {
                        if (indexS == "S" ||
                            indexS == "D") {
                            UnitAddAbility(u, id); // Add innate abilities
                        }
                        else {
							titanId = SubString(A2S(id), 1, 2);
							id = S2A("T" + titanId + "U" + indexS);
							SetPlayerAbilityAvailable(p, id, false);
							UnitAddAbility(u, id);
                        }
                    }
                }
            }
            
            // Re-trigger enter bounds?
            y = GetUnitY(u);
            SetUnitY(u, 1000000000);
            SetUnitY(u, y);
        }
        
        method printAbilityNames() {
            string abilities = "QWERSDF0123456789";
            integer i = 0;
            integer index = 0;
            integer id = 0;
            BJDebugMsg("Abilities for " + this.toString() + ":");
            for (0 <= i < StringLength(abilities)) {
                index = StringHash(SubString(abilities, i, 1 + i));
                if (this.abilityTable.has(index)) {
                    id = this.abilityTable[index];
                    if (id != 0) {
                        BJDebugMsg("\t" + GetObjectName(id));
                    }
                }
            }
        }
        
        method inRandomPool() -> boolean {
            return false;
        }
        
        public static method sneakyCreate() -> thistype {
            return thistype.create();
        }
    }
}

//! endzinc