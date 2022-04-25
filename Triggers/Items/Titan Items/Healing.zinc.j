//! zinc
library Healing requires ItemExtras, IsUnitTitanHunter, Insight {
    //Library to handle Titan heals. Identifying them and such
    private integer HEAL[17];
    private integer NHEAL = 17;
    
    //Returns if an ability is a healing ability
    public function isHeal(integer tempId) -> boolean {
        integer i = 0;
        for(0 <= i <= NHEAL) {
            if(tempId == HEAL[i]) {
                return true;
            }
        }
        return false;
    }	
    
    //Returns which ability
    public function whichHeal(integer tempId) -> integer {
        integer i = 0;
        for(0 <= i <= NHEAL) {
            if(tempId == HEAL[i]) {
                return HEAL[i];
            }
        }
        return 0;
    }
    
    public function hasHeal(unit caster) -> boolean {
        integer i = 0;
        integer tempLevel;
        for(0 <= i <= NHEAL) {
            tempLevel = GetUnitAbilityLevel(caster, HEAL[i]);
            if(tempLevel > 0) return true;
        }
        return false;
    }
    
    public function getHeal(unit u) -> integer {
        integer i = 0;
        integer tempLevel;
        for(0 <= i <= NHEAL) {
            tempLevel = GetUnitAbilityLevel(u, HEAL[i]);
            if(tempLevel > 0) {
                return HEAL[i];
            }
        }
        return 0;
    }
    
    public function getInsightBonus(unit u) -> real {
        real percentMana = 0.0;
        real healBonus = 0;
		if(UnitHasItemById(u, 'I04P')) {			//Crest of the Immortal
			percentMana = 0.15;
		}
		else {
			if(UnitHasItemById(u, 'I04P')) {		//Crown of Depths
				percentMana = 0.10;
			}
			else {
				if(UnitHasItemById(u, 'I06T')) {	//Summoner's Wrist Guard
					percentMana = 0.05;
				}
			}
		}
        return (I2R(BlzGetUnitMaxMana(u)) * percentMana) + healBonus;
    }
    
    private function onInit() {
        HEAL[0] = 'TMAE';
        HEAL[1] = 'A0CT';
        HEAL[2] = 'TTAE';
        HEAL[3] = 'TGAE';
        HEAL[4] = 'TLAE';
        HEAL[5] = 'TBAE';
        HEAL[6] = 'TDAE';
        HEAL[7] = 'TSAE';
        HEAL[8] = 'A07Y';
        HEAL[9] = 'TMNE';
        HEAL[10] = 'TGNE';
        HEAL[11] = 'TDNE';
        HEAL[12] = 'TBNE';
        HEAL[13] = 'TTNE';
        HEAL[14] = 'TLNE';
        HEAL[15] = 'TSNE';
        HEAL[16] = 'TVNE';
        HEAL[17] = 'A0D6';
    }
}
//! endzinc