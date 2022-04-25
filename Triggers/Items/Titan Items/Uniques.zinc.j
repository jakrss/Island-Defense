//! zinc
library Uniques {
    //Library to handle Titan uniques. Identifying them and such
    private integer UNIQUE[4];
    private integer NUNIQUE = 4;
    
    //Returns if an ability is a unique ability
    public function isUnique(integer tempId) -> boolean {
        integer i = 0;
        for(0 <= i <= NUNIQUE) {
            if(tempId == UNIQUE[i]) {
                return true;
            }
        }
        return false;
    }	
    
    //Returns which ability
    public function whichUnique(integer tempId) -> integer {
        integer i = 0;
        for(0 <= i <= NUNIQUE) {
            if(tempId == UNIQUE[i]) {
                return UNIQUE[i];
            }
        }
        return 0;
    }
    
    public function hasUnique(unit caster) -> boolean {
        integer i = 0;
        integer tempLevel;
        for(0 <= i <= NUNIQUE) {
            tempLevel = GetUnitAbilityLevel(caster, UNIQUE[i]);
            if(tempLevel > 0) return true;
        }
        return false;
    }
    
    public function getUnique(unit u) -> integer {
        integer i = 0;
        integer tempLevel;
        for(0 <= i <= NUNIQUE) {
            tempLevel = GetUnitAbilityLevel(u, UNIQUE[i]);
            if(tempLevel > 0) {
                return UNIQUE[i];
            }
        }
        return 0;
    }
    
    private function onInit() {
        UNIQUE[0] = 'TBAF';		//Bubonicus
        UNIQUE[1] = 'A099';		//Demonicus
        UNIQUE[2] = 'TGAR';		//Glacious
        UNIQUE[3] = 'TTA0';		//Granitacles
		UNIQUE[4] = 'TSAF';		//Noxious
        //UNIQUE[5] = '';		//Moltenious has passive unique
        //UNIQUE[6] = '';		//Voltron has passive unique
        //UNIQUE[7] = '';		//Lucidious has passive unique
        //UNIQUE[8] = '';		//Breezerious has passive unique
    }
}
//! endzinc