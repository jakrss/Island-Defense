//! zinc
library ApplyTitanUpgrades requires Players {
    function onInit() {
	trigger t = CreateTrigger();
	TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_FINISH);
	TriggerAddCondition(t, Condition(function() -> boolean {
	    unit t = GetTriggerUnit();
	    player p = GetOwningPlayer(t);
	    PlayerDataArray minions = PlayerData.withClass(1); //1 is Minion
	    PlayerData minion;
	    player tempPlayer;
	    PlayerData titan = PlayerData.findTitanPlayer();
	    integer upgradeId = GetResearched();
	    integer upgradeLvl;
	    integer i=0;
	    
	    if(titan == null || minions == null) return false;
	    
	    if(titan.player() == p) {
                BJDebugMsg("Titan Researched: " + I2S(upgradeId));
		upgradeLvl = GetPlayerTechCount(p, upgradeId, true);
		for(0 <= i < minions.size()) {
		    minion = minions.takeAt(i);
                    tempPlayer = minion.player();
		    SetPlayerTechResearched(minion.player(), upgradeId, upgradeLvl);
                    BJDebugMsg("Set Player("+I2S(GetPlayerId(tempPlayer))+") tech to " + I2S(upgradeLvl));
                    tempPlayer = null;
		}
	    }
	    t = null;
	    p = null;
	    minions.destroy();
	    return false;
	}));
	t=null;
    }
}
//! endzinc