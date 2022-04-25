//! zinc
library NatureReplant requires BUM, ShowTagFromUnit {
    private constant integer ABILITY_ID = 'REPL';
    private constant real salvageAmount = .75;
    private constant real dmgPerSec = 25; //okay flat value
    private hashtable plantTable = InitHashtable();
    
    //runs indefinitely until canceled orrrr yeah
    function replant() {
	timer t = GetExpiredTimer();
	integer th = GetHandleId(t);
	unit plant = LoadUnitHandle(plantTable, 0, th);
	real origHP = LoadReal(plantTable, 1, th);
	real origMP = LoadReal(plantTable, 2, th);
	real hp = getHealth(plant);
	real mp = getMana(plant);
	player p = GetOwningPlayer(plant);
	integer lumber = GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER);
        string s = "";
	
	if(hp < dmgPerSec) {
	    KillUnit(plant);
            s = "|ccf01bf4d+" + I2S(lumber) + "|r";
            if (GetLocalPlayer() == p) {
                ShowTagFromUnit(s, plant);
            }
            s = "";
	    SetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER, lumber + R2I((origHP + origMP) * salvageAmount));
	    FlushChildHashtable(plantTable, th);
	    DestroyTimer(t);
	} else {
	    setHealth(plant, hp - dmgPerSec);
	    if(mp > hp) {
		setMana(plant, mp - dmgPerSec * 2);
	    } else {
		//Not sure if this will be relevant, but I subtract 2X mana if it's greater than HP
		setMana(plant, mp - dmgPerSec);
	    }
	}
	t = null;
	plant = null;
	p = null;
    }

    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
	TriggerAddCondition(t, Condition(function() -> boolean {
	    unit getPlanted;
	    real hp;
	    real mp;
	    timer t;
	    integer th;
	    integer id = GetSpellAbilityId();
	    if(id == ABILITY_ID) {
		getPlanted = GetTriggerUnit();
		hp = getHealth(getPlanted);
		mp = getMana(getPlanted);
		t = CreateTimer();
		th = GetHandleId(t);
		SaveUnitHandle(plantTable, 0, th, getPlanted);
		SaveReal(plantTable, 1, th, hp);
		SaveReal(plantTable, 2, th, mp);
		TimerStart(t, 1, true, function replant);
		t = null;
		getPlanted = null;
	    }
	    return false;
	}));
        t = null;
    }
}

//! endzinc