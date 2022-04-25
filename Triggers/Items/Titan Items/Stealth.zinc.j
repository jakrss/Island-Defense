//! zinc
library Stealth {
    //Library to handle Titan stealth. Identifying them and such
    private integer STEALTH[17];
    private integer NSTEALTH = 17;
    
    //Returns if an ability is a stealth ability
    public function isStealth(integer tempId) -> boolean {
        integer i = 0;
        for(0 <= i <= NSTEALTH) {
            if(tempId == STEALTH[i]) {
                return true;
            }
        }
        return false;
    }	
    
    //Returns which ability
    public function whichStealth(integer tempId) -> integer {
        integer i = 0;
        for(0 <= i <= NSTEALTH) {
            if(tempId == STEALTH[i]) {
                return STEALTH[i];
            }
        }
        return 0;
    }
    
    public function hasStealth(unit caster) -> boolean {
        integer i = 0;
        integer tempLevel;
        for(0 <= i <= NSTEALTH) {
            tempLevel = GetUnitAbilityLevel(caster, STEALTH[i]);
            if(tempLevel > 0) return true;
        }
        return false;
    }
    
    public function getStealth(unit u) -> integer {
        integer i = 0;
        integer tempLevel;
        for(0 <= i <= NSTEALTH) {
            tempLevel = GetUnitAbilityLevel(u, STEALTH[i]);
            if(tempLevel > 0) {
                return STEALTH[i];
            }
        }
        return 0;
    }
    
    private function onInit() {
        STEALTH[0] = 'A0CA';		//Breezerious
        STEALTH[1] = 'TBAW';		//Bubonicus
        STEALTH[2] = 'A096';		//Demonicus
        STEALTH[3] = 'TGAW';		//Glacious
        STEALTH[4] = 'TTAW';		//Granitacles
        STEALTH[5] = 'TLAW';		//Lucidious
        STEALTH[6] = 'TMAW';		//Moltenious
        STEALTH[7] = 'TSAW';		//Noxious
        STEALTH[8] = 'TVA0';		//Voltron
        STEALTH[9] = 'TTNF';		//Granitacles Minion
        STEALTH[10] = 'TBNW';		//Bubonicus Minion
        STEALTH[11] = 'TDNW';		//Demonicus Minion
        STEALTH[12] = 'TTNW';		//Glacious Minion
        STEALTH[13] = 'TMNW';		//Moltenious Minion
        STEALTH[14] = 'TVNW';		//Voltron Minion
        STEALTH[15] = 'A0D9';		//Noxious Minion
        STEALTH[16] = 'TLNW';		//Lucidious Minion
        STEALTH[17] = 'A0DH';		//Breezerious Minion
    }
}
//! endzinc