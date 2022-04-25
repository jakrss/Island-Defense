//! zinc
library Scouting {
    //Library for identifying and dealing with Scouting functions
    private integer SCOUT[7];
    private integer NSCOUT = 7;
    
    //Returns if an ability is a scouting ability
    public function isScout(integer tempId) -> boolean {
        integer i = 0;
        for(0 <= i <= NSCOUT) {
            if(tempId == SCOUT[i]) {
                return true;
            }
        }
        return false;
    }	
    
    //Returns which ability
    public function whichScout(integer tempId) -> integer {
        integer i = 0;
        for(0 <= i <= NSCOUT) {
            if(tempId == SCOUT[i]) {
                return SCOUT[i];
            }
        }
        return 0;
    }
    
    public function hasScout(unit caster) -> boolean {
        integer i = 0;
        integer tempLevel;
        for(0 <= i <= NSCOUT) {
            tempLevel = GetUnitAbilityLevel(caster, SCOUT[i]);
            if(tempLevel > 0) return true;
        }
        return false;
    }
    
    public function getScout(unit u) -> integer {
        integer i = 0;
        integer tempLevel;
        
        for(0 <= i <= NSCOUT) {
            tempLevel = GetUnitAbilityLevel(u, SCOUT[i]);
            if(tempLevel > 0) {
                return SCOUT[i];
            }
        }
        return 0;
    }
	
    private function onInit() {
        SCOUT[0] = 'A08J';		//Demonicus
        SCOUT[1] = 'A09J';		//Glacious
        SCOUT[2] = 'A095';		//Lucidious
        SCOUT[3] = 'TMAD';		//Moltenious
        SCOUT[4] = 'TOTR';		//Noxious
        SCOUT[5] = 'TVAD';		//Voltron
        SCOUT[6] = 'A0DB';		//Breezerious
        SCOUT[7] = 'TTAD';		//Granitacles
        //SCOUT[8] = 'TBA0';			//Bubonicus shouldn't be affected
        //SCOUT[9] = 'TBA1';
        //SCOUT[10] = 'TBA2';
        //SCOUT[11] = 'TBA3';
        //SCOUT[12] = 'TBA4';
        //SCOUT[13] = 'TBA5';
        //SCOUT[14] = 'TBA6';
    }
}
//! endzinc