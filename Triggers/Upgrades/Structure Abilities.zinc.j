//! zinc
library StructureAbilities {
    //How many upgrades/abilities/units?
    //ALL CONFIG FOR UNIT, UPGRADE, AND ABILITY TYPES IS IN THE STRUCTURE ABILITIES AND CHECK STRUCTURE
    //IF ONE OR MORE UNITS HAVE MULTIPLE NEEDS HERE (LIKE DRAENEI TOWERS) YOU ALSO NEED TO ADD THEM TO
    //THE upgradeUnit METHOD (FOLLOW EXAMPLE)
    private constant integer UPGRADE_COUNT = 10;
    private constant integer ABILITY_COUNT = 10;
    private constant integer UNIT_ID_COUNT = 16;
    private integer UNIT_TYPES[];
    
    private struct StructureAbilities {
        unit structure;
        //We find these from the type ID of the unit
        integer abilityId = 0;
        integer upgradeId = 0;
        //If there's a second effect or ability or whatever put it in the correct one (look at Draenei's Crystal Focusing for example)
        //if it's 0 it won't do anything
        integer abilityIdTwo = 0;
        integer upgradeIdTwo = 0;
        //This boolean let's the system know if there's multiple abilities or researches
        boolean multiUpgrades = false;
        
        method upgradeUnit() {
            integer researchLevel = GetPlayerTechCount(GetOwningPlayer(this.structure), this.upgradeId, true);
            integer researchLevelTwo;
            integer abilityLevel, abilityLevelTwo;
            integer unitId = GetUnitTypeId(this.structure);
            //If the units abilityId is 0 it's Draenei mana walls right now (will need to make more specific if we add more later on)
            if(this.abilityId != 0) {
                abilityLevel = GetUnitAbilityLevel(this.structure, this.abilityId);
                if(abilityLevel > 0) SetUnitAbilityLevel(this.structure, this.abilityId, researchLevel + 1);
                //Second upgrades
                if(this.multiUpgrades) {
                    abilityLevelTwo = GetUnitAbilityLevel(this.structure, this.abilityIdTwo);
                    researchLevelTwo = GetPlayerTechCount(GetOwningPlayer(this.structure), this.upgradeIdTwo, true);
                    if(abilityLevelTwo > 0) {
                        SetUnitAbilityLevel(this.structure, this.abilityIdTwo, researchLevelTwo + 1);
                    } else if(this.upgradeIdTwo == 'R02G') {
                        //BlzSetUnitMaxMana(this.structure, 50 + (researchLevelTwo * 50)); //Blizz fixed this? Now applies even without
                    }
                }
            }
            this.destroy();
        }
        
        method getStructureData() {
            //We get the structures upgrade or ability data from the unit type
            integer unitId = GetUnitTypeId(this.structure);
            if(unitId == UNIT_TYPES[0] || unitId == UNIT_TYPES[1] || unitId == UNIT_TYPES[2] || unitId == UNIT_TYPES[14]) {
                //Draenei Crystal Focusing
                this.abilityId = 'A0DV';
                this.upgradeId = 'R049';
                this.abilityIdTwo = 0;
                this.upgradeIdTwo = 'R02G';
                this.multiUpgrades = true;
            } else if(unitId == UNIT_TYPES[3] || unitId == UNIT_TYPES[4]) {
                //Radioactive Magic Modules
                this.abilityId = 'A07U';
                this.upgradeId = 'R03S';
            } else if(unitId == UNIT_TYPES[5] || unitId == UNIT_TYPES[6]) {
                //Radioactive Frost Modules
                this.abilityId = 'A0F1';
                this.upgradeId = 'R03S';
            } else if(unitId == UNIT_TYPES[7] || unitId == UNIT_TYPES[8]) {
                //Radioactive Overload Module
                this.abilityId = 'A05C';
                this.upgradeId = 'R03S';
            } else if(unitId == UNIT_TYPES[9] || unitId == UNIT_TYPES[10]) {
                //Radioactive Rapid Module
                this.abilityId = 'A0F3';
                this.upgradeId = 'R03S';
            } else if(unitId == UNIT_TYPES[11]) {
                //Faerie Mana Burn Enhanced
                this.abilityId = 'A0A2';
                this.upgradeId = 'R02K';
            } else if(unitId == UNIT_TYPES[12]) {
                //Faerie Mana Burn Super
                this.abilityId = 'A0AI';
                this.upgradeId = 'R02K';
            } else if(unitId == UNIT_TYPES[13]) {
                this.abilityId = 'A0AJ';
                this.upgradeId = 'R02K';
            } else if(unitId == UNIT_TYPES[15]) {
				this.abilityId = 'A0FZ';
				this.upgradeId = 'R04L';
			}
            this.upgradeUnit();
        }
    }
    
    //Checks if the triggering structure should apply (also sets our variables)
    private function CheckStructure(unit s) -> boolean {
        integer i=0;
        //Crystal Focusing
        UNIT_TYPES[0] = 'o02B';
        UNIT_TYPES[1] = 'o02D';
        UNIT_TYPES[2] = 'o02C';
        //Magic Modules
        UNIT_TYPES[3] = 'h03Y';
        UNIT_TYPES[4] = 'h04B';
        //Frost Modules
        UNIT_TYPES[5] = 'h03T';
        UNIT_TYPES[6] = 'h04C';
        //Overload Modules
        UNIT_TYPES[7] = 'h047';
        UNIT_TYPES[8] = 'h048';
        //Rapid Modules
        UNIT_TYPES[9] = 'h049';
        UNIT_TYPES[10] = 'h04A';
        //Mystic Training
        UNIT_TYPES[11] = 'o01J';
        UNIT_TYPES[12] = 'o01L';
        UNIT_TYPES[13] = 'o01M';
        //Draenei Mana Wall
        UNIT_TYPES[14] = 'u019';
		//Pirate Explosive Walls
		UNIT_TYPES[15] = 'u011';
        while(i < UNIT_ID_COUNT) {
            if(GetUnitTypeId(s) == UNIT_TYPES[i]) {
                return true;
            }
            i=i+1;
        }
        return false;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_FINISH);
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH);
        TriggerAddCondition(t, function() -> boolean {
            unit structure = GetTriggerUnit();
            StructureAbilities s;
            if(CheckStructure(structure)) {
                s = StructureAbilities.create();
                s.structure = structure;
                s.getStructureData();
            }
            return false;
        });
        t=null;
    }
}
//! endzinc