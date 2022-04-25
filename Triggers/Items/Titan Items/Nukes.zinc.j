//! zinc
library Nukes requires ItemExtras, IsUnitTitanHunter {
    //Library to handle Titan nukes. Identifying them and such
    private integer NUKE[17];
    private integer NNUKE = 17;
    
    //Returns if an ability is a nuke ability
	public function isNuke(integer tempId) -> boolean {
        integer i = 0;
        for(0 <= i <= NNUKE) {
            if(tempId == NUKE[i]) {
                return true;
            }
        }
        return false;
    }	
    
    //Returns which ability
    public function whichNuke(integer tempId) -> integer {
        integer i = 0;
        for(0 <= i <= NNUKE) {
            if(tempId == NUKE[i]) {
                return NUKE[i];
            }
        }
        return 0;
    }
    
    public function hasNuke(unit caster) -> boolean {
        integer i = 0;
        integer tempLevel;
        for(0 <= i <= NNUKE) {
            tempLevel = GetUnitAbilityLevel(caster, NUKE[i]);
            if(tempLevel > 0) return true;
        }
        return false;
    }
    
    public function getNuke(unit u) -> integer {
        integer i = 0;
        integer tempLevel;
        
        for(0 <= i <= NNUKE) {
            tempLevel = GetUnitAbilityLevel(u, NUKE[i]);
            if(tempLevel > 0) {
                return NUKE[i];
            }
        }
        return 0;
    }
    
    public function getModifiers(unit u, unit target) -> real {
        if(UnitHasItemById(u, 'I07W') || UnitHasItemById(u, 'I06X')) {
            if(IsUnitTitanHunter(target)) {
				//BJDebugMsg("Amplifying damage");
                return 1.15;
            }
        }
        return 1.00;
    }
    
    private function onInit() {
        NUKE[0] = 'TMAQ';
        NUKE[1] = 'A094';
        NUKE[2] = 'TTAQ';
        NUKE[3] = 'TGAQ';
        NUKE[4] = 'TLAQ';
        NUKE[5] = 'TBAQ';
        NUKE[6] = 'A0DI';
        NUKE[7] = 'TSAQ';
        NUKE[8] = 'TVAQ';
        NUKE[9] = 'TMNQ';
        NUKE[10] = 'TGNQ';
        NUKE[11] = 'TDNQ';
        NUKE[12] = 'TBNQ';
        NUKE[13] = 'TTNQ';
        NUKE[14] = 'TLNQ';
        NUKE[15] = 'TSNQ';
        NUKE[16] = 'TVNQ';
        NUKE[17] = 'A0D5';
    }
}
//! endzinc