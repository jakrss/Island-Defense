//! zinc
library Ultimate {
    //Library to handle Titan ultimates. Identifying them and such
    private integer ULTIMATE[17];
    private integer NULTIMATE = 17;
    
    //Returns if an ability is a ultimate ability
    public function isUltimate(integer tempId) -> boolean {
        integer i = 0;
        for(0 <= i <= NULTIMATE) {
            if(tempId == ULTIMATE[i]) {
                return true;
            }
        }
        return false;
    }	
    
    //Returns which ability
    public function whichUltimate(integer tempId) -> integer {
        integer i = 0;
        for(0 <= i <= NULTIMATE) {
            if(tempId == ULTIMATE[i]) {
                return ULTIMATE[i];
            }
        }
        return 0;
    }
    
    public function hasUltimate(unit caster) -> boolean {
        integer i = 0;
        integer tempLevel;
        for(0 <= i <= NULTIMATE) {
            tempLevel = GetUnitAbilityLevel(caster, ULTIMATE[i]);
            if(tempLevel > 0) return true;
        }
        return false;
    }
    
    public function getUltimate(unit u) -> integer {
        integer i = 0;
        integer tempLevel;
        for(0 <= i <= NULTIMATE) {
            tempLevel = GetUnitAbilityLevel(u, ULTIMATE[i]);
            if(tempLevel > 0) {
                return ULTIMATE[i];
            }
        }
        return 0;
    }
    
    private function onInit() {
        ULTIMATE[0] = 'A0CY';		//Breezerious
        ULTIMATE[1] = 'TBAF';		//Bubonicus
        ULTIMATE[2] = 'A09B';		//Demonicus
        ULTIMATE[3] = 'TGAF';		//Glacious
        ULTIMATE[4] = 'TTAF';		//Granitacles
        ULTIMATE[5] = 'TLAF';		//Lucidious
        ULTIMATE[6] = 'A0NG';		//Moltenious
        ULTIMATE[7] = 'A092';		//Noxious
        ULTIMATE[8] = 'TVAF';		//Voltron
        ULTIMATE[9] = 'TTNF';		//Granitacles Minion
        ULTIMATE[10] = 'TBNF';	//Bubonicus Minion
        ULTIMATE[11] = 'TDNE';	//Demonicus Minion
        ULTIMATE[12] = 'TGNF';	//Glacious Minion
        ULTIMATE[13] = 'TMNF';	//Moltenious Minion
        ULTIMATE[14] = 'TVNF';	//Voltron Minion
        ULTIMATE[15] = 'TSNF';	//Noxious Minion
        ULTIMATE[16] = 'TLNF';	//Lucidious Minion
        ULTIMATE[17] = 'TDNF';	//Breezerious Minion
    }
}
//! endzinc